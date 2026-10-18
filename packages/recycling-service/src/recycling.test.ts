import { describe, it, expect, beforeEach } from "vitest";
import { BUY_RATES, recordRecycling, getRecyclingRecord, _clearStore } from "./recycling";
import { RecyclingRecord } from "@ecomins/shared";

beforeEach(() => {
  _clearStore();
});

describe("BUY_RATES", () => {
  it("has correct rate for scrap_metal", () => {
    expect(BUY_RATES.scrap_metal).toBe(15);
  });

  it("has correct rate for paper", () => {
    expect(BUY_RATES.paper).toBe(5);
  });

  it("has correct rate for plastic", () => {
    expect(BUY_RATES.plastic).toBe(8);
  });

  it("has correct rate for e_waste", () => {
    expect(BUY_RATES.e_waste).toBe(25);
  });
});

describe("recordRecycling — payout calculation", () => {
  const categories: RecyclingRecord["waste_category"][] = [
    "scrap_metal",
    "paper",
    "plastic",
    "e_waste",
  ];

  for (const category of categories) {
    it(`calculates payout_amount correctly for ${category}`, () => {
      const weight = 3.5;
      const record = recordRecycling("job-1", "cust-1", category, weight, "cash");
      expect(record.payout_amount).toBe(weight * BUY_RATES[category]);
    });
  }

  it("calculates payout for fractional weight", () => {
    const record = recordRecycling("job-2", "cust-1", "plastic", 0.5, "cash");
    expect(record.payout_amount).toBe(0.5 * 8);
  });

  it("calculates payout for zero weight", () => {
    const record = recordRecycling("job-3", "cust-1", "paper", 0, "cash");
    expect(record.payout_amount).toBe(0);
  });
});

describe("recordRecycling — record storage", () => {
  it("stores and retrieves a record by jobId", () => {
    const record = recordRecycling("job-10", "cust-2", "e_waste", 2, "cash");
    const retrieved = getRecyclingRecord("job-10");
    expect(retrieved).not.toBeNull();
    expect(retrieved!.id).toBe(record.id);
    expect(retrieved!.job_id).toBe("job-10");
    expect(retrieved!.customer_id).toBe("cust-2");
    expect(retrieved!.waste_category).toBe("e_waste");
    expect(retrieved!.weight_kg).toBe(2);
    expect(retrieved!.payout_amount).toBe(50);
  });

  it("stores payout_preference = cash correctly", () => {
    recordRecycling("job-11", "cust-3", "scrap_metal", 1, "cash");
    const record = getRecyclingRecord("job-11");
    expect(record!.payout_preference).toBe("cash");
  });

  it("stores payout_preference = eco_points correctly", () => {
    recordRecycling("job-12", "cust-4", "paper", 1, "eco_points");
    const record = getRecyclingRecord("job-12");
    expect(record!.payout_preference).toBe("eco_points");
  });

  it("sets payout_status to pending on creation", () => {
    recordRecycling("job-13", "cust-5", "plastic", 1, "cash");
    const record = getRecyclingRecord("job-13");
    expect(record!.payout_status).toBe("pending");
  });
});

describe("getRecyclingRecord", () => {
  it("returns null for unknown jobId", () => {
    expect(getRecyclingRecord("nonexistent-job")).toBeNull();
  });

  it("returns null after store is cleared", () => {
    recordRecycling("job-20", "cust-6", "plastic", 5, "cash");
    _clearStore();
    expect(getRecyclingRecord("job-20")).toBeNull();
  });
});
