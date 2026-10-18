import { describe, it, expect, vi, beforeEach } from "vitest";
import { getOrders, getRewards } from "./orders";

const API_BASE = "http://localhost:3000";
const TOKEN = "test-token";
const CUSTOMER_ID = "cust-123";

beforeEach(() => {
  vi.unstubAllGlobals();
});

describe("getOrders", () => {
  it("GETs /jobs?customer_id=... and returns job array", async () => {
    const mockJobs = [
      {
        id: "job-1",
        service_type: "cleaning",
        status: "completed",
        price: 500,
        created_at: "2024-01-01T00:00:00Z",
        before_photo_url: null,
        after_photo_url: null,
      },
    ];
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: true, json: async () => mockJobs })
    );
    const orders = await getOrders(CUSTOMER_ID, API_BASE, TOKEN);
    expect(orders).toHaveLength(1);
    expect(orders[0].id).toBe("job-1");
    expect(fetch).toHaveBeenCalledWith(
      `${API_BASE}/jobs?customer_id=${CUSTOMER_ID}`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
  });

  it("returns empty array when customer has no orders", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: true, json: async () => [] })
    );
    const orders = await getOrders(CUSTOMER_ID, API_BASE, TOKEN);
    expect(orders).toEqual([]);
  });

  it("throws on API error", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 401,
        json: async () => ({ error: { message: "Unauthorized" } }),
      })
    );
    await expect(getOrders(CUSTOMER_ID, API_BASE, TOKEN)).rejects.toThrow("Unauthorized");
  });
});

describe("getRewards", () => {
  it("GETs /rewards/:customerId and returns points and eco_score", async () => {
    const mockRewards = { points: 150, eco_score: 42 };
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: true, json: async () => mockRewards })
    );
    const rewards = await getRewards(CUSTOMER_ID, API_BASE, TOKEN);
    expect(rewards.points).toBe(150);
    expect(rewards.eco_score).toBe(42);
    expect(fetch).toHaveBeenCalledWith(
      `${API_BASE}/rewards/${CUSTOMER_ID}`,
      expect.objectContaining({ headers: expect.objectContaining({ Authorization: `Bearer ${TOKEN}` }) })
    );
  });

  it("throws on API error", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 404,
        json: async () => ({ error: { message: "Customer not found" } }),
      })
    );
    await expect(getRewards(CUSTOMER_ID, API_BASE, TOKEN)).rejects.toThrow("Customer not found");
  });
});
