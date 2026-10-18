import { describe, it, expect, beforeEach, vi } from "vitest";
import { getJobs, createJob, assignWorker, updateJobStatus } from "./jobs";

const API = "https://api.example.com";
const TOKEN = "tok-admin";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("getJobs", () => {
  it("GETs /jobs with auth header", async () => {
    const jobs = [{ id: "j1", status: "pending" }];
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => jobs });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getJobs({}, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(jobs);
  });

  it("appends status filter to query string", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => [] });
    vi.stubGlobal("fetch", fetchMock);

    await getJobs({ status: "completed" }, API, TOKEN);

    const calledUrl: string = fetchMock.mock.calls[0][0];
    expect(calledUrl).toContain("status=completed");
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 401,
      json: async () => ({ error: { message: "Unauthorized" } }),
    }));

    await expect(getJobs({}, API, TOKEN)).rejects.toThrow("Unauthorized");
  });
});

describe("createJob", () => {
  it("POSTs to /jobs with required fields", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({ job_id: "j1" }) });
    vi.stubGlobal("fetch", fetchMock);

    const result = await createJob(
      { service_type: "cleaning", location: "Zone A", scheduled_time: "2024-01-01T10:00:00Z" },
      API, TOKEN
    );

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs`,
      expect.objectContaining({ method: "POST" })
    );
    expect(result).toEqual({ job_id: "j1" });
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 400,
      json: async () => ({ error: { message: "Missing required fields" } }),
    }));

    await expect(
      createJob({ service_type: "", location: "", scheduled_time: "" }, API, TOKEN)
    ).rejects.toThrow("Missing required fields");
  });
});

describe("assignWorker", () => {
  it("POSTs to /assign-worker with job_id and worker_id", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await assignWorker("j1", "w1", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/assign-worker`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ job_id: "j1", worker_id: "w1" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 409,
      json: async () => ({ error: { message: "Worker not eligible" } }),
    }));

    await expect(assignWorker("j1", "w1", API, TOKEN)).rejects.toThrow("Worker not eligible");
  });
});

describe("updateJobStatus", () => {
  it("PATCHes /jobs/:id with status and reason", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await updateJobStatus("j1", "cancelled", "Admin override", API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/jobs/j1`,
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ status: "cancelled", reason: "Admin override" }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 404,
      json: async () => ({ error: { message: "Job not found" } }),
    }));

    await expect(updateJobStatus("j99", "cancelled", "reason", API, TOKEN)).rejects.toThrow("Job not found");
  });
});
