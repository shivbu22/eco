import { describe, it, expect, beforeEach, vi } from "vitest";
import { getWorkers, reviewKyc, assignZone, getWorkerProfile } from "./workers";

const API = "https://api.example.com";
const TOKEN = "tok-admin";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("getWorkers", () => {
  it("GETs /workers with auth header", async () => {
    const workers = [{ id: "w1", kyc_status: "verified" }];
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => workers });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getWorkers(API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(workers);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 403,
      json: async () => ({ error: { message: "Forbidden" } }),
    }));

    await expect(getWorkers(API, TOKEN)).rejects.toThrow("Forbidden");
  });
});

describe("reviewKyc", () => {
  it("PATCHes /workers/:id/kyc/review with approved=true", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await reviewKyc("w1", true, undefined, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/w1/kyc/review`,
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ approved: true, reason: undefined }),
      })
    );
  });

  it("PATCHes with approved=false and reason", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await reviewKyc("w2", false, "ID unclear", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/w2/kyc/review`,
      expect.objectContaining({
        body: JSON.stringify({ approved: false, reason: "ID unclear" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 404,
      json: async () => ({ error: { message: "Worker not found" } }),
    }));

    await expect(reviewKyc("w99", true, undefined, API, TOKEN)).rejects.toThrow("Worker not found");
  });
});

describe("assignZone", () => {
  it("PATCHes /workers/:id/zone with zone_id", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await assignZone("w1", "zone-5", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/w1/zone`,
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ zone_id: "zone-5" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 400,
      json: async () => ({ error: { message: "Invalid zone" } }),
    }));

    await expect(assignZone("w1", "bad-zone", API, TOKEN)).rejects.toThrow("Invalid zone");
  });
});

describe("getWorkerProfile", () => {
  it("GETs /workers/:id", async () => {
    const profile = { id: "w1", total_jobs: 42, rating: 4.8 };
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => profile });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getWorkerProfile("w1", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/w1`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(profile);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 404,
      json: async () => ({ error: { message: "Worker not found" } }),
    }));

    await expect(getWorkerProfile("w99", API, TOKEN)).rejects.toThrow("Worker not found");
  });
});
