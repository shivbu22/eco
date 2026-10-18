import { describe, it, expect, beforeEach } from "vitest";
import {
  calculateEarnings,
  getEarningsSummary,
  getEarningsByWorker,
  _resetStore,
} from "./earnings";

beforeEach(() => {
  _resetStore();
});

describe("calculateEarnings", () => {
  it("computes net_amount = gross * (1 - commission)", () => {
    const record = calculateEarnings("w1", "j1", 100, 0.2);
    expect(record.net_amount).toBeCloseTo(80);
    expect(record.gross_amount).toBe(100);
    expect(record.commission_rate).toBe(0.2);
    expect(record.worker_id).toBe("w1");
    expect(record.job_id).toBe("j1");
  });

  it("net_amount is 0 when commission rate is 1", () => {
    const record = calculateEarnings("w1", "j1", 50, 1);
    expect(record.net_amount).toBe(0);
  });

  it("net_amount equals gross when commission rate is 0", () => {
    const record = calculateEarnings("w1", "j1", 75, 0);
    expect(record.net_amount).toBe(75);
  });

  it("net_amount is always >= 0 for valid commission rates in [0, 1]", () => {
    const rates = [0, 0.1, 0.25, 0.5, 0.99, 1];
    for (const rate of rates) {
      const record = calculateEarnings("w1", `j-${rate}`, 200, rate);
      expect(record.net_amount).toBeGreaterThanOrEqual(0);
    }
  });

  it("stores the record and returns it with an id and created_at", () => {
    const record = calculateEarnings("w2", "j2", 60, 0.15);
    expect(record.id).toBeTruthy();
    expect(record.created_at).toBeTruthy();
    const stored = getEarningsByWorker("w2");
    expect(stored).toHaveLength(1);
    expect(stored[0].id).toBe(record.id);
  });
});

describe("getEarningsByWorker", () => {
  it("returns only records for the specified worker", () => {
    calculateEarnings("workerA", "j1", 100, 0.1);
    calculateEarnings("workerA", "j2", 200, 0.1);
    calculateEarnings("workerB", "j3", 150, 0.1);

    const aRecords = getEarningsByWorker("workerA");
    const bRecords = getEarningsByWorker("workerB");

    expect(aRecords).toHaveLength(2);
    expect(bRecords).toHaveLength(1);
    expect(aRecords.every((r) => r.worker_id === "workerA")).toBe(true);
    expect(bRecords.every((r) => r.worker_id === "workerB")).toBe(true);
  });

  it("returns empty array for unknown worker", () => {
    expect(getEarningsByWorker("unknown")).toEqual([]);
  });
});

describe("getEarningsSummary", () => {
  it("returns zero totals for a worker with no records", () => {
    const summary = getEarningsSummary("nobody");
    expect(summary).toEqual({ today: 0, week: 0, all_time: 0 });
  });

  it("includes today's earnings in today, week, and all_time", () => {
    calculateEarnings("w1", "j1", 100, 0.2); // net = 80, created now
    const summary = getEarningsSummary("w1");
    expect(summary.today).toBeCloseTo(80);
    expect(summary.week).toBeCloseTo(80);
    expect(summary.all_time).toBeCloseTo(80);
  });

  it("accumulates multiple records in all_time", () => {
    calculateEarnings("w1", "j1", 100, 0.2); // net = 80
    calculateEarnings("w1", "j2", 50, 0.1);  // net = 45
    const summary = getEarningsSummary("w1");
    expect(summary.all_time).toBeCloseTo(125);
  });

  it("separates records from different workers", () => {
    calculateEarnings("wA", "j1", 200, 0.25); // net = 150
    calculateEarnings("wB", "j2", 100, 0.1);  // net = 90

    expect(getEarningsSummary("wA").all_time).toBeCloseTo(150);
    expect(getEarningsSummary("wB").all_time).toBeCloseTo(90);
  });
});
