import http from "http";
import {
  createWorker,
  getWorker,
  updateAvailability,
  submitKyc,
  reviewKyc,
  updateZone,
} from "./worker.js";

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
      // POST /workers — create worker
      if (method === "POST" && url === "/workers") {
        const body = (await readBody(req)) as Record<string, unknown>;
        const result = createWorker({
          name: body.name as string,
          phone: body.phone as string,
          zone_id: body.zone_id as string,
          skills: body.skills as string[],
        });
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 201, result.worker);
      }

      // GET /workers/:id
      const workerIdMatch = url.match(/^\/workers\/([^/]+)$/);
      if (method === "GET" && workerIdMatch) {
        const result = getWorker(workerIdMatch[1]);
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 200, result.worker);
      }

      // PATCH /workers/:id/availability
      const availabilityMatch = url.match(/^\/workers\/([^/]+)\/availability$/);
      if (method === "PATCH" && availabilityMatch) {
        const body = (await readBody(req)) as Record<string, unknown>;
        if (typeof body.available !== "boolean") {
          return send(res, 400, errorResponse("INVALID_INPUT", "available (boolean) is required"));
        }
        const result = updateAvailability(availabilityMatch[1], body.available);
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 200, result.worker);
      }

      // POST /workers/:id/kyc — submit KYC
      const kycSubmitMatch = url.match(/^\/workers\/([^/]+)\/kyc$/);
      if (method === "POST" && kycSubmitMatch) {
        const body = (await readBody(req)) as Record<string, unknown>;
        const result = submitKyc(kycSubmitMatch[1], {
          id_document_url: body.id_document_url as string,
          selfie_url: body.selfie_url as string,
        });
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 201, result.submission);
      }

      // PATCH /workers/:id/kyc/review — admin review
      const kycReviewMatch = url.match(/^\/workers\/([^/]+)\/kyc\/review$/);
      if (method === "PATCH" && kycReviewMatch) {
        const body = (await readBody(req)) as Record<string, unknown>;
        if (typeof body.approved !== "boolean") {
          return send(res, 400, errorResponse("INVALID_INPUT", "approved (boolean) is required"));
        }
        const result = reviewKyc(kycReviewMatch[1], {
          approved: body.approved,
          reason: body.reason as string | undefined,
          reviewed_by: body.reviewed_by as string | undefined,
        });
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 200, { worker: result.worker, submission: result.submission });
      }

      // PATCH /workers/:id/zone — update zone
      const zoneMatch = url.match(/^\/workers\/([^/]+)\/zone$/);
      if (method === "PATCH" && zoneMatch) {
        const body = (await readBody(req)) as Record<string, unknown>;
        const result = updateZone(zoneMatch[1], body.zone_id as string);
        if (!result.success) {
          return send(res, result.status, errorResponse(result.code, result.message));
        }
        return send(res, 200, result.worker);
      }

      send(res, 404, errorResponse("NOT_FOUND", "Route not found"));
    } catch {
      send(res, 500, errorResponse("INTERNAL_ERROR", "Internal server error"));
    }
  });
}
