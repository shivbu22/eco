import { describe, it, expect, beforeEach, vi } from "vitest";
import { toggleAvailability, getEarnings } from "./earnings";

const API = "https://api.example.com";
const TOKEN = "tok-test";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("toggleAvailability", () => {
  it("PATCHes /workers/:id/availability with available=true", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await toggleAvailability("worker-1", true, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/workers/worker-1/availability`,
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ available: true }),
        headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }),
      })
    );
  });

  it("PATCHes /workers/:id/availability with available=false", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await toggleAvailability("worker-1", false, API, TOKEN);

    const call = fetchMock.mock.calls[0];
    expect(JSON.parse(call[1].body)).toEqual({ available: false });
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 404,
      json: async () => ({ error: { message: "Worker not found" } }),
    }));

    await expect(toggleAvailability("bad-id", true, API, TOKEN)).rejects.toThrow("Worker not found");
  });
});

describe("getEarnings", () => {
  it("GETs /earnings/:workerId with auth header", async () => {
    const summary = { today: 50, week: 300, all_time: 5000 };
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => summary,
    });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getEarnings("worker-1", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/earnings/worker-1`,
      expect.objectContaining({
        headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }),
      })
    );
    expect(result).toEqual(summary);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 403,
      json: async () => ({ error: { message: "Forbidden" } }),
    }));

    await expect(getEarnings("worker-1", API, TOKEN)).rejects.toThrow("Forbidden");
  });
});
