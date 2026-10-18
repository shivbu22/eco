import { describe, it, expect, beforeEach, vi } from "vitest";
import { getAvailableJobs, acceptJob, rejectJob, startJob, completeJob } from "./jobs";

const API = "https://api.example.com";
const TOKEN = "tok-test";

beforeEach(() => {
  vi.unstubAllGlobals();
});

// ── Job feed (20.2) ──────────────────────────────────────────────────────────

describe("getAvailableJobs", () => {
  it("GETs /available-jobs with auth header", async () => {
    const jobs = [{ id: "job-1" }];
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => jobs,
    });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getAvailableJobs(API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/available-jobs`,
      expect.objectContaining({
        headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }),
      })
    );
    expect(result).toEqual(jobs);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 401,
      json: async () => ({ error: { message: "Unauthorized" } }),
    }));

    await expect(getAvailableJobs(API, TOKEN)).rejects.toThrow("Unauthorized");
  });
});

describe("acceptJob", () => {
  it("POSTs to /jobs/:id/accept", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await acceptJob("job-1", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs/job-1/accept`,
      expect.objectContaining({ method: "POST" })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 409,
      json: async () => ({ error: { message: "Job already taken" } }),
    }));

    await expect(acceptJob("job-1", API, TOKEN)).rejects.toThrow("Job already taken");
  });
});

describe("rejectJob", () => {
  it("POSTs to /jobs/:id/reject", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await rejectJob("job-2", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs/job-2/reject`,
      expect.objectContaining({ method: "POST" })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 404,
      json: async () => ({ error: { message: "Job not found" } }),
    }));

    await expect(rejectJob("job-99", API, TOKEN)).rejects.toThrow("Job not found");
  });
});

// ── Proof upload (20.3) ──────────────────────────────────────────────────────

describe("startJob", () => {
  it("POSTs to /jobs/:id/start with before_photo_url", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await startJob("job-1", "https://before.jpg", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs/job-1/start`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ before_photo_url: "https://before.jpg" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 400,
      json: async () => ({ error: { message: "before_photo_url required" } }),
    }));

    await expect(startJob("job-1", "", API, TOKEN)).rejects.toThrow("before_photo_url required");
  });
});

describe("completeJob", () => {
  it("POSTs to /jobs/:id/complete with after_photo_url", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);

    await completeJob("job-1", "https://after.jpg", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs/job-1/complete`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ after_photo_url: "https://after.jpg" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false,
      status: 400,
      json: async () => ({ error: { message: "after_photo_url required" } }),
    }));

    await expect(completeJob("job-1", "", API, TOKEN)).rejects.toThrow("after_photo_url required");
  });
});
