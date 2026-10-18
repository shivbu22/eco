import { describe, it, expect, beforeEach } from "vitest";
import { awardPoints, redeemPoints, getAccount, _clearStore } from "./rewards";

beforeEach(() => {
  _clearStore();
});

describe("getAccount", () => {
  it("returns zero balance and eco_score for a new customer", () => {
    const account = getAccount("customer-1");
    expect(account.customer_id).toBe("customer-1");
    expect(account.points_balance).toBe(0);
    expect(account.eco_score).toBe(0);
  });

  it("returns the same account on repeated calls", () => {
    getAccount("customer-1");
    awardPoints("customer-1", 50, "job-1");
    const account = getAccount("customer-1");
    expect(account.points_balance).toBe(50);
  });
});

describe("awardPoints", () => {
  it("increases points_balance by the awarded amount", () => {
    const account = awardPoints("customer-1", 100, "job-1");
    expect(account.points_balance).toBe(100);
  });

  it("increases eco_score by the awarded amount", () => {
    const account = awardPoints("customer-1", 100, "job-1");
    expect(account.eco_score).toBe(100);
  });

  it("accumulates balance and eco_score across multiple awards", () => {
    awardPoints("customer-1", 50, "job-1");
    const account = awardPoints("customer-1", 75, "job-2");
    expect(account.points_balance).toBe(125);
    expect(account.eco_score).toBe(125);
  });
});

describe("redeemPoints", () => {
  it("decreases points_balance by the redeemed amount", () => {
    awardPoints("customer-1", 200, "job-1");
    const account = redeemPoints("customer-1", 50);
    expect(account.points_balance).toBe(150);
  });

  it("allows redeeming the full balance", () => {
    awardPoints("customer-1", 100, "job-1");
    const account = redeemPoints("customer-1", 100);
    expect(account.points_balance).toBe(0);
  });

  it("throws an error when balance is insufficient", () => {
    awardPoints("customer-1", 30, "job-1");
    expect(() => redeemPoints("customer-1", 50)).toThrow(/Insufficient balance/);
  });

  it("leaves balance unchanged when redemption fails", () => {
    awardPoints("customer-1", 30, "job-1");
    try {
      redeemPoints("customer-1", 50);
    } catch {
      // expected
    }
    const account = getAccount("customer-1");
    expect(account.points_balance).toBe(30);
  });

  it("balance never goes negative", () => {
    awardPoints("customer-1", 10, "job-1");
    expect(() => redeemPoints("customer-1", 11)).toThrow();
    expect(getAccount("customer-1").points_balance).toBeGreaterThanOrEqual(0);
  });
});
