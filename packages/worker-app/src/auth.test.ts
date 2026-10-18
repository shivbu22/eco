import { describe, it, expect, beforeEach, vi } from "vitest";
import { requestOtp, verifyOtp, submitKyc, getToken, clearToken } from "./auth";

const API = "https://api.example.com";

beforeEach(() => {
  clearToken();
  vi.unstubAllGlobals();
});

describe("requestOtp", () => {
  it("POSTs to /auth/request-otp", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await requestOtp("+1234567890", API);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/auth/request-otp`,
      expect.objectContaining({ method: "POST" })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 400,
      json: async () => ({ error: { message: "Invalid phone" } }),
    }));

    await expect(requestOtp("bad", API)).rejects.toThrow("Invalid phone");
  });
});

describe("verifyOtp", () => {
  it("POSTs to /auth/verify-otp and stores token", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ token: "tok-abc" }),
    }));

    const token = await verifyOtp("+1234567890", "123456", API);

    expect(token).toBe("tok-abc");
    expect(getToken()).toBe("tok-abc");
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 401,
      json: async () => ({ error: { message: "Invalid OTP" } }),
    }));

    await expect(verifyOtp("+1234567890", "000000", API)).rejects.toThrow("Invalid OTP");
    expect(getToken()).toBeNull();
  });
});

describe("getToken / clearToken", () => {
  it("returns null before any login", () => {
    expect(getToken()).toBeNull();
  });

  it("clearToken resets to null", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ token: "tok-xyz" }),
    }));
    await verifyOtp("+1234567890", "123456", API);
    expect(getToken()).toBe("tok-xyz");

    clearToken();
    expect(getToken()).toBeNull();
  });
});

describe("submitKyc", () => {
  it("POSTs to /workers/:id/kyc with auth header", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await submitKyc("worker-1", "https://id.url", "https://selfie.url", API, "tok-abc");

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/worker-1/kyc`,
      expect.objectContaining({
        method: "POST",
        headers: expect.objectContaining({ Authorization: "Bearer tok-abc" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 422,
      json: async () => ({ error: { message: "Missing selfie" } }),
    }));

    await expect(
      submitKyc("worker-1", "https://id.url", "", API, "tok")
    ).rejects.toThrow("Missing selfie");
  });
});
