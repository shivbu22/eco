import { describe, it, expect, vi, beforeEach } from "vitest";
import { requestOtp, verifyOtp, getToken, clearToken } from "./auth";

const API_BASE = "http://localhost:3000";

beforeEach(() => {
  clearToken();
  vi.unstubAllGlobals();
});

describe("requestOtp", () => {
  it("POSTs to /auth/request-otp with the phone number", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) }));
    await requestOtp("+911234567890", API_BASE);
    expect(fetch).toHaveBeenCalledWith(
      `${API_BASE}/auth/request-otp`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ phone: "+911234567890" }),
      })
    );
  });

  it("throws when the server returns an error", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 429,
        json: async () => ({ error: { message: "Too many attempts" } }),
      })
    );
    await expect(requestOtp("+911234567890", API_BASE)).rejects.toThrow("Too many attempts");
  });
});

describe("verifyOtp", () => {
  it("POSTs to /auth/verify-otp and returns the token", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ token: "jwt-abc123" }),
      })
    );
    const token = await verifyOtp("+911234567890", "123456", API_BASE);
    expect(token).toBe("jwt-abc123");
    expect(fetch).toHaveBeenCalledWith(
      `${API_BASE}/auth/verify-otp`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ phone: "+911234567890", otp: "123456" }),
      })
    );
  });

  it("stores the token in the in-memory store", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ token: "stored-token" }),
      })
    );
    await verifyOtp("+911234567890", "123456", API_BASE);
    expect(getToken()).toBe("stored-token");
  });

  it("throws on invalid OTP response", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 401,
        json: async () => ({ error: { message: "Invalid OTP" } }),
      })
    );
    await expect(verifyOtp("+911234567890", "000000", API_BASE)).rejects.toThrow("Invalid OTP");
  });
});

describe("getToken / clearToken", () => {
  it("returns null before any login", () => {
    expect(getToken()).toBeNull();
  });

  it("clearToken resets the stored token", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ token: "some-token" }),
      })
    );
    await verifyOtp("+911234567890", "123456", API_BASE);
    expect(getToken()).toBe("some-token");
    clearToken();
    expect(getToken()).toBeNull();
  });
});
