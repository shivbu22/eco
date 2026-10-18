import { describe, it, expect, beforeEach } from "vitest";
import {
  createWorker,
  getWorker,
  updateAvailability,
  submitKyc,
  reviewKyc,
  updateZone,
  _clearWorkerStore,
  _clearKycStore,
} from "./worker.js";

beforeEach(() => {
  _clearWorkerStore();
  _clearKycStore();
});

// --- createWorker ---

describe("createWorker", () => {
  it("succeeds with valid fields", () => {
    const result = createWorker({
      name: "Alice",
      phone: "+2348012345678",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.name).toBe("Alice");
    expect(result.worker.phone).toBe("+2348012345678");
    expect(result.worker.zone_id).toBe("zone-1");
    expect(result.worker.skills).toEqual(["cleaning"]);
    expect(result.worker.kyc_status).toBe("pending");
    expect(result.worker.availability).toBe(true);
    expect(typeof result.worker.id).toBe("string");
  });

  it("fails when name is missing", () => {
    const result = createWorker({
      name: "",
      phone: "+2348012345678",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.code).toBe("INVALID_INPUT");
  });

  it("fails when phone is missing", () => {
    const result = createWorker({
      name: "Alice",
      phone: "",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
  });

  it("fails when zone_id is missing", () => {
    const result = createWorker({
      name: "Alice",
      phone: "+2348012345678",
      zone_id: "",
      skills: ["cleaning"],
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
  });

  it("fails when skills is an empty array", () => {
    const result = createWorker({
      name: "Alice",
      phone: "+2348012345678",
      zone_id: "zone-1",
      skills: [],
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/skills/i);
  });

  it("fails when skills is not an array", () => {
    const result = createWorker({
      name: "Alice",
      phone: "+2348012345678",
      zone_id: "zone-1",
      skills: null as unknown as string[],
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
  });
});

// --- getWorker ---

describe("getWorker", () => {
  it("returns the worker when found", () => {
    const created = createWorker({
      name: "Bob",
      phone: "+2348099999999",
      zone_id: "zone-2",
      skills: ["recycling"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = getWorker(created.worker.id);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.id).toBe(created.worker.id);
  });

  it("returns 404 for unknown id", () => {
    const result = getWorker("nonexistent-id");
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(404);
  });
});

// --- updateAvailability ---

describe("updateAvailability", () => {
  it("toggles availability to false immediately", () => {
    const created = createWorker({
      name: "Carol",
      phone: "+2348011111111",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = updateAvailability(created.worker.id, false);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.availability).toBe(false);
  });

  it("toggles availability back to true", () => {
    const created = createWorker({
      name: "Carol",
      phone: "+2348011111111",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    updateAvailability(created.worker.id, false);
    const result = updateAvailability(created.worker.id, true);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.availability).toBe(true);
  });

  it("returns 404 for unknown worker", () => {
    const result = updateAvailability("no-such-id", false);
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(404);
  });
});

// --- submitKyc ---

describe("submitKyc", () => {
  it("creates a pending KYC submission", () => {
    const created = createWorker({
      name: "Dave",
      phone: "+2348022222222",
      zone_id: "zone-3",
      skills: ["waste_management"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = submitKyc(created.worker.id, {
      id_document_url: "https://example.com/id.jpg",
      selfie_url: "https://example.com/selfie.jpg",
    });
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.submission.status).toBe("pending");
    expect(result.submission.worker_id).toBe(created.worker.id);
    expect(result.submission.reviewed_by).toBeNull();
    expect(result.submission.rejection_reason).toBeNull();
  });

  it("returns 404 for unknown worker", () => {
    const result = submitKyc("no-such-id", {
      id_document_url: "https://example.com/id.jpg",
      selfie_url: "https://example.com/selfie.jpg",
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(404);
  });
});

// --- reviewKyc ---

describe("reviewKyc — approval", () => {
  it("sets kyc_status to verified on approval", () => {
    const created = createWorker({
      name: "Eve",
      phone: "+2348033333333",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    submitKyc(created.worker.id, {
      id_document_url: "https://example.com/id.jpg",
      selfie_url: "https://example.com/selfie.jpg",
    });

    const result = reviewKyc(created.worker.id, { approved: true, reviewed_by: "admin-1" });
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.kyc_status).toBe("verified");
    expect(result.submission.status).toBe("approved");
  });
});

describe("reviewKyc — rejection", () => {
  it("sets kyc_status to rejected with a reason", () => {
    const created = createWorker({
      name: "Frank",
      phone: "+2348044444444",
      zone_id: "zone-2",
      skills: ["recycling"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    submitKyc(created.worker.id, {
      id_document_url: "https://example.com/id.jpg",
      selfie_url: "https://example.com/selfie.jpg",
    });

    const result = reviewKyc(created.worker.id, {
      approved: false,
      reason: "ID document is blurry",
      reviewed_by: "admin-1",
    });
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.kyc_status).toBe("rejected");
    expect(result.submission.status).toBe("rejected");
    expect(result.submission.rejection_reason).toBe("ID document is blurry");
  });

  it("fails rejection without a reason", () => {
    const created = createWorker({
      name: "Grace",
      phone: "+2348055555555",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    submitKyc(created.worker.id, {
      id_document_url: "https://example.com/id.jpg",
      selfie_url: "https://example.com/selfie.jpg",
    });

    const result = reviewKyc(created.worker.id, { approved: false });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/reason/i);
  });

  it("returns 404 when no pending KYC submission exists", () => {
    const created = createWorker({
      name: "Hank",
      phone: "+2348066666666",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = reviewKyc(created.worker.id, { approved: true });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(404);
  });
});

// --- updateZone ---

describe("updateZone", () => {
  it("updates the worker zone_id", () => {
    const created = createWorker({
      name: "Ivy",
      phone: "+2348077777777",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = updateZone(created.worker.id, "zone-99");
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.worker.zone_id).toBe("zone-99");
  });

  it("returns 404 for unknown worker", () => {
    const result = updateZone("no-such-id", "zone-5");
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(404);
  });

  it("returns 400 when zone_id is empty", () => {
    const created = createWorker({
      name: "Jack",
      phone: "+2348088888888",
      zone_id: "zone-1",
      skills: ["cleaning"],
    });
    expect(created.success).toBe(true);
    if (!created.success) return;

    const result = updateZone(created.worker.id, "");
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
  });
});
