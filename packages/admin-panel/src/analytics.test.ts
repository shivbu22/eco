import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  getAnalyticsSummary,
  exportAnalyticsCsv,
  getPricing,
  updatePricing,
  getContracts,
  createContract,
} from "./analytics";

const API = "https://api.example.com";
const TOKEN = "tok-admin";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("getAnalyticsSummary", () => {
  it("GETs /analytics/summary with no filters", async () => {
    const summary = { total_jobs: 100, total_revenue: 5000 };
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => summary });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getAnalyticsSummary({}, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/analytics/summary`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(summary);
  });

  it("appends filters to query string", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await getAnalyticsSummary({ from: "2024-01-01", to: "2024-01-31", zone_id: "z1", service_type: "cleaning" }, API, TOKEN);

    const calledUrl: string = fetchMock.mock.calls[0][0];
    expect(calledUrl).toContain("from=2024-01-01");
    expect(calledUrl).toContain("to=2024-01-31");
    expect(calledUrl).toContain("zone_id=z1");
    expect(calledUrl).toContain("service_type=cleaning");
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 500,
      json: async () => ({ error: { message: "Internal error" } }),
    }));

    await expect(getAnalyticsSummary({}, API, TOKEN)).rejects.toThrow("Internal error");
  });
});

describe("exportAnalyticsCsv", () => {
  it("GETs /analytics/export and returns text", async () => {
    const csv = "id,status\nj1,completed";
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, text: async () => csv });
    vi.stubGlobal("fetch", fetchMock);

    const result = await exportAnalyticsCsv({}, API, TOKEN);

    const calledUrl: string = fetchMock.mock.calls[0][0];
    expect(calledUrl).toContain("/analytics/export");
    expect(result).toBe(csv);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 400,
      json: async () => ({ error: { message: "Invalid filter" } }),
    }));

    await expect(exportAnalyticsCsv({ from: "bad" }, API, TOKEN)).rejects.toThrow("Invalid filter");
  });
});

describe("getPricing", () => {
  it("GETs /pricing", async () => {
    const rules = [{ id: "p1", service_type: "cleaning", base_rate: 100 }];
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => rules });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getPricing(API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/pricing`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(rules);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 401,
      json: async () => ({ error: { message: "Unauthorized" } }),
    }));

    await expect(getPricing(API, TOKEN)).rejects.toThrow("Unauthorized");
  });
});

describe("updatePricing", () => {
  it("PATCHes /pricing/:id with updates", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({}) });
    vi.stubGlobal("fetch", fetchMock);

    await updatePricing("p1", { base_rate: 150 }, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/pricing/p1`,
      expect.objectContaining({
        method: "PATCH",
        body: JSON.stringify({ base_rate: 150 }),
      })
    );
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 404,
      json: async () => ({ error: { message: "Pricing rule not found" } }),
    }));

    await expect(updatePricing("p99", {}, API, TOKEN)).rejects.toThrow("Pricing rule not found");
  });
});

describe("getContracts", () => {
  it("GETs /contracts", async () => {
    const contracts = [{ id: "c1", status: "active" }];
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => contracts });
    vi.stubGlobal("fetch", fetchMock);

    const result = await getContracts(API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/contracts`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
    expect(result).toEqual(contracts);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 403,
      json: async () => ({ error: { message: "Forbidden" } }),
    }));

    await expect(getContracts(API, TOKEN)).rejects.toThrow("Forbidden");
  });
});

describe("createContract", () => {
  it("POSTs to /contracts with input", async () => {
    const contract = { id: "c1", client_name: "Acme Corp" };
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => contract });
    vi.stubGlobal("fetch", fetchMock);

    const input = {
      client_name: "Acme Corp",
      service_scope: "weekly cleaning",
      zone_id: "z1",
      start_date: "2024-01-01",
      end_date: "2024-12-31",
      monthly_rate: 5000,
    };
    const result = await createContract(input, API, TOKEN);

    expect(fetchMock).toHaveBeenCalledWith(
      `${API}/contracts`,
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify(input),
      })
    );
    expect(result).toEqual(contract);
  });

  it("throws on non-ok response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: false, status: 400,
      json: async () => ({ error: { message: "Missing required fields" } }),
    }));

    await expect(createContract({}, API, TOKEN)).rejects.toThrow("Missing required fields");
  });
});
