import { describe, it, expect, vi, beforeEach } from "vitest";
import { validateBookingPhoto, submitBooking } from "./booking";

const API_BASE = "http://localhost:3000";
const TOKEN = "test-token";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("validateBookingPhoto", () => {
  it("accepts JPEG under 10MB", () => {
    const result = validateBookingPhoto("image/jpeg", 5 * 1024 * 1024);
    expect(result.valid).toBe(true);
    expect(result.error).toBeUndefined();
  });

  it("accepts PNG under 10MB", () => {
    const result = validateBookingPhoto("image/png", 1024);
    expect(result.valid).toBe(true);
  });

  it("rejects files over 10MB", () => {
    const result = validateBookingPhoto("image/jpeg", 11 * 1024 * 1024);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/10 MB/);
  });

  it("rejects invalid MIME types", () => {
    const result = validateBookingPhoto("application/pdf", 1024);
    expect(result.valid).toBe(false);
    expect(result.error).toMatch(/Invalid file type/);
  });

  it("rejects GIF even if small", () => {
    const result = validateBookingPhoto("image/gif", 100);
    expect(result.valid).toBe(false);
  });

  it("rejects exactly at 10MB + 1 byte", () => {
    const result = validateBookingPhoto("image/png", 10 * 1024 * 1024 + 1);
    expect(result.valid).toBe(false);
  });

  it("accepts exactly 10MB", () => {
    const result = validateBookingPhoto("image/jpeg", 10 * 1024 * 1024);
    expect(result.valid).toBe(true);
  });
});

describe("submitBooking", () => {
  it("POSTs to /jobs and returns jobId", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ job_id: "job-xyz" }),
      })
    );
    const result = await submitBooking(
      {
        serviceType: "cleaning",
        location: { lat: 12.97, lng: 77.59, address: "123 Main St" },
      },
      API_BASE,
      TOKEN
    );
    expect(result.jobId).toBe("job-xyz");
    expect(fetch).toHaveBeenCalledWith(
      `${API_BASE}/jobs`,
      expect.objectContaining({ method: "POST" })
    );
  });

  it("includes Authorization header", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ job_id: "job-abc" }),
      })
    );
    await submitBooking(
      { serviceType: "recycling", location: { lat: 0, lng: 0, address: "Addr" } },
      API_BASE,
      TOKEN
    );
    const [, options] = (fetch as ReturnType<typeof vi.fn>).mock.calls[0];
    expect(options.headers["Authorization"]).toBe(`Bearer ${TOKEN}`);
  });

  it("throws on API error", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 400,
        json: async () => ({ error: { message: "Missing required fields" } }),
      })
    );
    await expect(
      submitBooking(
        { serviceType: "cleaning", location: { lat: 0, lng: 0, address: "" } },
        API_BASE,
        TOKEN
      )
    ).rejects.toThrow("Missing required fields");
  });
});
