import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// ── Helpers ──────────────────────────────────────────────────────────────────

function ok(res: functions.Response, body: unknown, status = 200) {
  res.status(status).json(body);
}

function err(res: functions.Response, status: number, code: string, message: string) {
  res.status(status).json({ error: { code, message } });
}

// ── BOOKING SERVICE ──────────────────────────────────────────────────────────
// POST /jobs          — create a job
// GET  /jobs          — list jobs for a customer (?customer_id=)
// GET  /jobs/:id      — get a single job
// PATCH /jobs/:id     — update job status

export const jobs = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }

  const path = req.path; // e.g. "/" or "/<id>"
  const jobId = path.replace(/^\//, "").split("/")[0];

  // POST /jobs — create job
  if (req.method === "POST" && (!jobId || jobId === "")) {
    const { service_type, location, zone_id, customer_id, price } = req.body as Record<string, unknown>;
    if (!service_type || !location || !zone_id || !customer_id) {
      return err(res, 400, "INVALID_INPUT", "service_type, location, zone_id, customer_id are required");
    }
    const now = new Date().toISOString();
    const ref = db.collection("jobs").doc();
    const job = {
      id: ref.id,
      customer_id,
      worker_id: null,
      service_type,
      status: "pending",
      location,
      zone_id,
      price: typeof price === "number" ? price : 0,
      before_photo_url: null,
      after_photo_url: null,
      scheduled_time: null,
      created_at: now,
      updated_at: now,
    };
    await ref.set(job);
    return ok(res, { job_id: ref.id, ...job }, 201);
  }

  // GET /jobs?customer_id= — list jobs
  if (req.method === "GET" && (!jobId || jobId === "")) {
    const customerId = req.query["customer_id"] as string | undefined;
    if (!customerId) return err(res, 400, "MISSING_PARAM", "customer_id query param required");
    const snap = await db.collection("jobs").where("customer_id", "==", customerId).orderBy("created_at", "desc").get();
    return ok(res, snap.docs.map((d) => d.data()));
  }

  // GET /jobs/:id
  if (req.method === "GET" && jobId) {
    const doc = await db.collection("jobs").doc(jobId).get();
    if (!doc.exists) return err(res, 404, "NOT_FOUND", "Job not found");
    return ok(res, doc.data());
  }

  // PATCH /jobs/:id — update status
  if (req.method === "PATCH" && jobId) {
    const { status, worker_id } = req.body as Record<string, unknown>;
    const patch: Record<string, unknown> = { updated_at: new Date().toISOString() };
    if (status) patch["status"] = status;
    if (worker_id) patch["worker_id"] = worker_id;
    await db.collection("jobs").doc(jobId).update(patch);
    const updated = await db.collection("jobs").doc(jobId).get();
    return ok(res, updated.data());
  }

  return err(res, 404, "NOT_FOUND", "Route not found");
});

// ── REWARDS SERVICE ──────────────────────────────────────────────────────────
// GET  /rewards/:customerId          — get account
// POST /rewards/:customerId/award    — award points
// POST /rewards/:customerId/redeem   — redeem points

export const rewards = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }

  const parts = req.path.replace(/^\//, "").split("/");
  const customerId = parts[0];
  const action = parts[1]; // "award" | "redeem" | undefined

  if (!customerId) return err(res, 400, "MISSING_PARAM", "customerId required");

  const ref = db.collection("rewards").doc(customerId);

  async function getOrCreate() {
    const doc = await ref.get();
    if (!doc.exists) {
      const account = { customer_id: customerId, points_balance: 0, eco_score: 0 };
      await ref.set(account);
      return account;
    }
    return doc.data() as { customer_id: string; points_balance: number; eco_score: number };
  }

  // GET /rewards/:customerId
  if (req.method === "GET" && !action) {
    const account = await getOrCreate();
    return ok(res, account);
  }

  // POST /rewards/:customerId/award
  if (req.method === "POST" && action === "award") {
    const { points } = req.body as { points?: number };
    if (typeof points !== "number" || points <= 0) return err(res, 400, "INVALID_INPUT", "points must be a positive number");
    const account = await getOrCreate();
    const updated = {
      points_balance: account.points_balance + points,
      eco_score: account.eco_score + points,
    };
    await ref.update(updated);
    return ok(res, { ...account, ...updated });
  }

  // POST /rewards/:customerId/redeem
  if (req.method === "POST" && action === "redeem") {
    const { points } = req.body as { points?: number };
    if (typeof points !== "number" || points <= 0) return err(res, 400, "INVALID_INPUT", "points must be a positive number");
    const account = await getOrCreate();
    if (account.points_balance < points) {
      return err(res, 400, "INSUFFICIENT_BALANCE", `Available: ${account.points_balance}, requested: ${points}`);
    }
    const updated = { points_balance: account.points_balance - points };
    await ref.update(updated);
    return ok(res, { ...account, ...updated });
  }

  return err(res, 404, "NOT_FOUND", "Route not found");
});

// ── TRACKING SERVICE ─────────────────────────────────────────────────────────
// POST /tracking/:jobId/location  — worker pushes location update
// GET  /tracking/:jobId/location  — get last known location

export const tracking = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }

  const parts = req.path.replace(/^\//, "").split("/");
  const jobId = parts[0];
  const action = parts[1]; // "location"

  if (!jobId || action !== "location") return err(res, 404, "NOT_FOUND", "Route not found");

  const ref = db.collection("tracking").doc(jobId);

  // POST — worker pushes location
  if (req.method === "POST") {
    const { worker_id, lat, lng, status } = req.body as Record<string, unknown>;
    if (typeof lat !== "number" || typeof lng !== "number") {
      return err(res, 400, "INVALID_INPUT", "lat and lng are required numbers");
    }
    const location = { worker_id, jobId, lat, lng, status: status ?? null, updated_at: new Date().toISOString() };
    await ref.set(location, { merge: true });
    return ok(res, location);
  }

  // GET — customer polls last location
  if (req.method === "GET") {
    const doc = await ref.get();
    if (!doc.exists) return err(res, 404, "NOT_FOUND", "No location data for this job");
    return ok(res, doc.data());
  }

  return err(res, 405, "METHOD_NOT_ALLOWED", "Method not allowed");
});
