import { describe, it, expect, beforeEach } from "vitest";
import {
  createJob,
  assignJob,
  setEnRoute,
  startJob,
  completeJob,
  cancelJob,
  _clearJobStore,
} from "./booking.js";

// Helper: create a job and return its id
const validInput = {
  service_type: "cleaning",
  location: { lat: 1.0, lng: 2.0, address: "1 Test St" },
  zone_id: "zone-1",
  customer_id: "cust-1",
  price: 100,
};

function makeJob() {
  const r = createJob(validInput);
  if (!r.success) throw new Error("createJob failed: " + r.message);
  return r.job.id;
}

beforeEach(() => {
  _clearJobStore();
});

// --- startJob ---

describe("startJob", () => {
  it("returns 400 when before_photo_url is missing", () => {
    const id = makeJob();
    const r = startJob(id, null);
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
    expect(r.message).toMatch(/before_photo_url/i);
  });

  it("returns 400 when before_photo_url is empty string", () => {
    const id = makeJob();
    const r = startJob(id, "  ");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
  });

  it("transitions pending → in_progress with a photo", () => {
    const id = makeJob();
    const r = startJob(id, "https://example.com/before.jpg");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("in_progress");
    expect(r.job.before_photo_url).toBe("https://example.com/before.jpg");
  });

  it("transitions assigned → in_progress with a photo", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    const r = startJob(id, "https://example.com/before.jpg");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("in_progress");
  });

  it("transitions en_route → in_progress with a photo", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    setEnRoute(id);
    const r = startJob(id, "https://example.com/before.jpg");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("in_progress");
  });

  it("returns 409 when job is already in_progress", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    const r = startJob(id, "https://example.com/before2.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
    expect(r.currentStatus).toBe("in_progress");
  });

  it("returns 409 when job is completed", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    completeJob(id, "https://example.com/after.jpg");
    const r = startJob(id, "https://example.com/before2.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
  });

  it("returns 409 when job is cancelled", () => {
    const id = makeJob();
    cancelJob(id, "customer request");
    const r = startJob(id, "https://example.com/before.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
  });
});

// --- completeJob ---

describe("completeJob", () => {
  it("returns 400 when after_photo_url is missing", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    const r = completeJob(id, null);
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
    expect(r.message).toMatch(/after_photo_url/i);
  });

  it("returns 400 when after_photo_url is empty string", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    const r = completeJob(id, "");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
  });

  it("transitions in_progress → completed and sets earningsTriggered", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    const r = completeJob(id, "https://example.com/after.jpg");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("completed");
    expect(r.job.after_photo_url).toBe("https://example.com/after.jpg");
    expect(r.earningsTriggered).toBe(true);
  });

  it("returns 409 when job is pending (not in_progress)", () => {
    const id = makeJob();
    const r = completeJob(id, "https://example.com/after.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
    expect(r.currentStatus).toBe("pending");
  });

  it("returns 409 when job is assigned (not in_progress)", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    const r = completeJob(id, "https://example.com/after.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
    expect(r.currentStatus).toBe("assigned");
  });

  it("returns 409 when job is en_route (not in_progress)", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    setEnRoute(id);
    const r = completeJob(id, "https://example.com/after.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
    expect(r.currentStatus).toBe("en_route");
  });

  it("returns 409 when job is already completed", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    completeJob(id, "https://example.com/after.jpg");
    const r = completeJob(id, "https://example.com/after2.jpg");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
  });
});

// --- cancelJob ---

describe("cancelJob", () => {
  it("returns 400 when reason is missing", () => {
    const id = makeJob();
    const r = cancelJob(id, null);
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
    expect(r.message).toMatch(/reason/i);
  });

  it("returns 400 when reason is empty string", () => {
    const id = makeJob();
    const r = cancelJob(id, "  ");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(400);
  });

  it("cancels a pending job", () => {
    const id = makeJob();
    const r = cancelJob(id, "customer changed mind");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("cancelled");
  });

  it("cancels an assigned job", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    const r = cancelJob(id, "worker unavailable");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("cancelled");
  });

  it("cancels an en_route job", () => {
    const id = makeJob();
    assignJob(id, "worker-1");
    setEnRoute(id);
    const r = cancelJob(id, "emergency");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("cancelled");
  });

  it("cancels an in_progress job", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    const r = cancelJob(id, "safety concern");
    expect(r.success).toBe(true);
    if (!r.success) return;
    expect(r.job.status).toBe("cancelled");
  });

  it("returns 409 when job is already completed", () => {
    const id = makeJob();
    startJob(id, "https://example.com/before.jpg");
    completeJob(id, "https://example.com/after.jpg");
    const r = cancelJob(id, "too late");
    expect(r.success).toBe(false);
    if (r.success) return;
    expect(r.status).toBe(409);
    expect(r.currentStatus).toBe("completed");
  });
});
