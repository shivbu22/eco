import http from "http";
import { storePricingRule, updatePricingRule, getActiveRule, computeTotal } from "./pricing.js";

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
      // POST /pricing — create a new pricing rule
      if (method === "POST" && url === "/pricing") {
        const body = (await readBody(req)) as Record<string, unknown>;
        const { service_type, zone_id, base_rate, tax_rate, surcharge } = body;

        if (
          typeof service_type !== "string" ||
          typeof zone_id !== "string" ||
          typeof base_rate !== "number" ||
          typeof tax_rate !== "number" ||
          typeof surcharge !== "number"
        ) {
          return send(res, 400, errorResponse("INVALID_INPUT", "Missing or invalid fields"));
        }

        const rule = storePricingRule({ service_type, zone_id, base_rate, tax_rate, surcharge });
        return send(res, 201, rule);
      }

      // PATCH /pricing/:id — update an existing rule
      const patchMatch = url.match(/^\/pricing\/([^/]+)$/);
      if (method === "PATCH" && patchMatch) {
        const id = patchMatch[1];
        const body = (await readBody(req)) as Record<string, unknown>;
        const updates: Record<string, number> = {};

        if (typeof body.base_rate === "number") updates.base_rate = body.base_rate;
        if (typeof body.tax_rate === "number") updates.tax_rate = body.tax_rate;
        if (typeof body.surcharge === "number") updates.surcharge = body.surcharge;

        const updated = updatePricingRule(id, updates);
        if (!updated) {
          return send(res, 404, errorResponse("NOT_FOUND", "Pricing rule not found"));
        }
        return send(res, 200, updated);
      }

      // GET /pricing/:service_type/:zone_id — get active rule and total
      const getMatch = url.match(/^\/pricing\/([^/]+)\/([^/]+)$/);
      if (method === "GET" && getMatch) {
        const service_type = decodeURIComponent(getMatch[1]);
        const zone_id = decodeURIComponent(getMatch[2]);

        const rule = getActiveRule(service_type, zone_id);
        if (!rule) {
          return send(res, 404, errorResponse("NOT_FOUND", "No active pricing rule found"));
        }

        const total = computeTotal(rule);
        return send(res, 200, {
          base: rule.base_rate,
          tax: rule.tax_rate,
          surcharge: rule.surcharge,
          total,
          rule,
        });
      }

      send(res, 404, errorResponse("NOT_FOUND", "Route not found"));
    } catch (err) {
      send(res, 500, errorResponse("INTERNAL_ERROR", "Internal server error"));
    }
  });
}
