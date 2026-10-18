import { describe, it, expect, beforeEach } from "vitest";
import {
  createJob,
  validateImage,
  validateCustomerProfile,
  _clearJobStore,
} from "./booking.js";

beforeEach(() => {
  _clearJobStore();
});

// --- validateImage ---

describe("validateImage", () => {
  it("accepts a valid JPEG under 10MB", () => {
    const result = validateImage("image/jpeg", 5 * 1024 * 1024);
    expect(result.valid).toBe(true);
  });

  it("accepts a valid PNG under 10MB", () => {
    const result = validateImage("image/png", 1024);
    expect(result.valid).toBe(true);
  });

  it("accepts exactly 10MB", () => {
    const result = validateImage("image/jpeg", 10 * 1024 * 1024);
    expect(result.valid).toBe(true);
  });

  it("rejects an invalid MIME type with 400-level error info", () => {
    const result = validateImage("image/gif", 1024);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/invalid file type/i);
    expect(result.error).toContain("image/gif");
  });

  it("rejects a PDF MIME type", () => {
    const result = validateImage("application/pdf", 1024);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/invalid file type/i);
  });

  it("rejects a file over 10MB", () => {
    const result = validateImage("image/jpeg", 10 * 1024 * 1024 + 1);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/exceeds/i);
  });

  it("rejects a large PNG", () => {
    const result = validateImage("image/png", 20 * 1024 * 1024);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/exceeds/i);
  });
});

// --- validateCustomerProfile ---

describe("validateCustomerProfile", () => {
  it("accepts a complete profile", () => {
    const result = validateCustomerProfile({ id: "c1", name: "Alice", address: "123 Main St" });
    expect(result.valid).toBe(true);
  });

  it("rejects a profile with missing name", () => {
    const result = validateCustomerProfile({ id: "c1", address: "123 Main St" });
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/name/i);
  });

  it("rejects a profile with empty name", () => {
    const result = validateCustomerProfile({ id: "c1", name: "  ", address: "123 Main St" });
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/name/i);
  });

  it("rejects a profile with missing address", () => {
    const result = validateCustomerProfile({ id: "c1", name: "Alice" });
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/address/i);
  });

  it("rejects a profile with empty address", () => {
    const result = validateCustomerProfile({ id: "c1", name: "Alice", address: "" });
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/address/i);
  });
});

// --- createJob ---

const validJobInput = {
  service_type: "cleaning",
  location: { lat: 1.234, lng: 5.678, address: "456 Oak Ave" },
  zone_id: "zone-1",
  customer_id: "customer-abc",
  price: 150,
};

describe("createJob", () => {
  it("creates a job with status 'pending' and a unique ID", () => {
    const result = createJob(validJobInput);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.job.status).toBe("pending");
    expect(typeof result.job.id).toBe("string");
    expect(result.job.id.length).toBeGreaterThan(0);
  });

  it("returns unique IDs for different jobs", () => {
    const r1 = createJob(validJobInput);
    const r2 = createJob(validJobInput);
    expect(r1.success).toBe(true);
    expect(r2.success).toBe(true);
    if (!r1.success || !r2.success) return;
    expect(r1.job.id).not.toBe(r2.job.id);
  });

  it("stores the correct fields on the job", () => {
    const result = createJob(validJobInput);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.job.service_type).toBe("cleaning");
    expect(result.job.customer_id).toBe("customer-abc");
    expect(result.job.zone_id).toBe("zone-1");
    expect(result.job.location.lat).toBe(1.234);
    expect(result.job.location.lng).toBe(5.678);
    expect(result.job.location.address).toBe("456 Oak Ave");
    expect(result.job.price).toBe(150);
    expect(result.job.worker_id).toBeNull();
  });

  it("defaults price to 0 when not provided", () => {
    const { price: _, ...inputWithoutPrice } = validJobInput;
    const result = createJob(inputWithoutPrice);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(result.job.price).toBe(0);
  });

  it("returns 400 when service_type is missing", () => {
    const result = createJob({ ...validJobInput, service_type: "" });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/service_type/i);
  });

  it("returns 400 when customer_id is missing", () => {
    const result = createJob({ ...validJobInput, customer_id: "" });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/customer_id/i);
  });

  it("returns 400 when zone_id is missing", () => {
    const result = createJob({ ...validJobInput, zone_id: "" });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/zone_id/i);
  });

  it("returns 400 when location.lat is missing", () => {
    const result = createJob({
      ...validJobInput,
      location: { lat: undefined as unknown as number, lng: 5.678, address: "456 Oak Ave" },
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/location\.lat/i);
  });

  it("returns 400 when location.lng is missing", () => {
    const result = createJob({
      ...validJobInput,
      location: { lat: 1.234, lng: undefined as unknown as number, address: "456 Oak Ave" },
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/location\.lng/i);
  });

  it("returns 400 when location.address is missing", () => {
    const result = createJob({
      ...validJobInput,
      location: { lat: 1.234, lng: 5.678, address: "" },
    });
    expect(result.success).toBe(false);
    if (result.success) return;
    expect(result.status).toBe(400);
    expect(result.message).toMatch(/location\.address/i);
  });

  it("sets created_at and updated_at as ISO strings", () => {
    const result = createJob(validJobInput);
    expect(result.success).toBe(true);
    if (!result.success) return;
    expect(() => new Date(result.job.created_at)).not.toThrow();
    expect(() => new Date(result.job.updated_at)).not.toThrow();
  });
});
