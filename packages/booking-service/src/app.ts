import http from "http";
import { createJob, validateImage, validateCustomerProfile } from "./booking.js";

function readBody(req: http.IncomingMessage): Promise<unknown> {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk));
    req.on("end", () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch {
        reject(new Error("Invalid JSON"));
      }
    });
    req.on("error", reject);
  });
}

function send(res: http.ServerResponse, status: number, body: unknown): void {
  const json = JSON.stringify(body);
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(json);
}

function errorResponse(code: string, message: string) {
  return { error: { code, message } };
}

export function createApp(): http.Server {
  return http.createServer(async (req, res) => {
    const url = req.url ?? "/";
    const method = req.method ?? "GET";

    try {
      // POST /jobs — create a new job
      if (method === "POST" && url === "/jobs") {
        const body = (await readBody(req)) as Record<string, unknown>;

        // Validate customer profile completeness if provided
        if (body.customer_profile) {
          const profileValidation = validateCustomerProfile(
            body.customer_profile as { id: string; name?: string; address?: string }
          );
          if (!profileValidation.valid) {
            return send(res, 400, errorResponse("INCOMPLETE_PROFILE", profileValidation.error!));
          }
        }

        // Validate photo if provided
        if (body.photo_mime_type !== undefined || body.photo_size_bytes !== undefined) {
          const imageValidation = validateImage(
            body.photo_mime_type as string,
            body.photo_size_bytes as number
          );
          if (!imageValidation.valid) {
            return send(res, 400, errorResponse("INVALID_IMAGE", imageValidation.error!));
          }
        }

        const result = createJob({
          service_type: body.service_type as string,
          location: body.location as { lat: number; lng: number; address: string },
          zone_id: body.zone_id as string,
          customer_id: body.customer_id as string,
          price: body.price as number | undefined,
          scheduled_time: body.scheduled_time as string | undefined,
          photo_url: body.photo_url as string | undefined,
        });

        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }

        return send(res, 201, { job_id: result.job.id, job: result.job });
      }

      // GET /jobs/:id
      const jobIdMatch = url.match(/^\/jobs\/([^/]+)$/);
      if (method === "GET" && jobIdMatch) {
        const { getJob } = await import("./booking.js");
        const job = getJob(jobIdMatch[1]);
        if (!job) {
          return send(res, 404, errorResponse("NOT_FOUND", "Job not found"));
        }
        return send(res, 200, job);
      }

      send(res, 404, errorResponse("NOT_FOUND", "Route not found"));
    } catch {
      send(res, 500, errorResponse("INTERNAL_ERROR", "Internal server error"));
    }
  });
}
