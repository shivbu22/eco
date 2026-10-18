import { describe, it, expect, beforeEach } from "vitest";
import {
  storePricingRule,
  updatePricingRule,
  getActiveRule,
  computeTotal,
  _clearPricingStore,
} from "./pricing.js";

beforeEach(() => {
  _clearPricingStore();
});

describe("storePricingRule", () => {
  it("stores a rule and returns it with an id and effective_from", () => {
    const before = new Date();
    const rule = storePricingRule({
      service_type: "cleaning",
      zone_id: "zone-1",
      base_rate: 100,
      tax_rate: 0.18,
      surcharge: 10,
    });
    const after = new Date();

    expect(rule.id).toBeTruthy();
    expect(rule.service_type).toBe("cleaning");
    expect(rule.zone_id).toBe("zone-1");
    expect(rule.base_rate).toBe(100);
    expect(rule.tax_rate).toBe(0.18);
    expect(rule.surcharge).toBe(10);

    const effectiveFrom = new Date(rule.effective_from);
    expect(effectiveFrom.getTime()).toBeGreaterThanOrEqual(before.getTime());
    expect(effectiveFrom.getTime()).toBeLessThanOrEqual(after.getTime());
  });

  it("stores multiple rules independently", () => {
    const r1 = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.1, surcharge: 5 });
    const r2 = storePricingRule({ service_type: "recycling", zone_id: "z1", base_rate: 50, tax_rate: 0.05, surcharge: 0 });

    expect(r1.id).not.toBe(r2.id);
    expect(r1.service_type).toBe("cleaning");
    expect(r2.service_type).toBe("recycling");
  });
});

describe("computeTotal", () => {
  it("computes total = base_rate * (1 + tax_rate) + surcharge", () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });
    // 100 * 1.18 + 10 = 128
    expect(computeTotal(rule)).toBeCloseTo(128, 5);
  });

  it("computes total with zero tax and zero surcharge", () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 200, tax_rate: 0, surcharge: 0 });
    expect(computeTotal(rule)).toBeCloseTo(200, 5);
  });

  it("computes total with surcharge only", () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 50, tax_rate: 0, surcharge: 25 });
    expect(computeTotal(rule)).toBeCloseTo(75, 5);
  });

  it("computes total with fractional tax rate", () => {
    const rule = storePricingRule({ service_type: "waste", zone_id: "z2", base_rate: 80, tax_rate: 0.05, surcharge: 5 });
    // 80 * 1.05 + 5 = 89
    expect(computeTotal(rule)).toBeCloseTo(89, 5);
  });
});

describe("getActiveRule", () => {
  it("returns the stored rule when queried after effective_from", () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });
    const found = getActiveRule("cleaning", "z1");
    expect(found).not.toBeNull();
    expect(found!.id).toBe(rule.id);
  });

  it("returns null when no rule exists for the service/zone", () => {
    storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });
    expect(getActiveRule("recycling", "z1")).toBeNull();
    expect(getActiveRule("cleaning", "z2")).toBeNull();
  });

  it("returns null when queried before the rule's effective_from", () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });
    // Query at a time before the rule was created
    const past = new Date(new Date(rule.effective_from).getTime() - 1000);
    expect(getActiveRule("cleaning", "z1", past)).toBeNull();
  });

  it("returns the latest rule when multiple rules exist for the same service/zone", async () => {
    const old = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });

    // Small delay to ensure different timestamps
    await new Promise((r) => setTimeout(r, 5));

    const newer = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 150, tax_rate: 0.2, surcharge: 20 });

    const active = getActiveRule("cleaning", "z1");
    expect(active!.id).toBe(newer.id);
    expect(active!.base_rate).toBe(150);
  });
});

describe("updatePricingRule", () => {
  it("updates fields and sets a new effective_from", async () => {
    const original = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });
    const originalTime = new Date(original.effective_from).getTime();

    await new Promise((r) => setTimeout(r, 5));

    const updated = updatePricingRule(original.id, { base_rate: 200 });
    expect(updated).not.toBeNull();
    expect(updated!.base_rate).toBe(200);
    expect(updated!.tax_rate).toBe(0.18); // unchanged
    expect(updated!.surcharge).toBe(10);  // unchanged
    expect(new Date(updated!.effective_from).getTime()).toBeGreaterThan(originalTime);
  });

  it("returns null for a non-existent id", () => {
    expect(updatePricingRule("non-existent-id", { base_rate: 999 })).toBeNull();
  });

  it("after update, getActiveRule returns the updated rule", async () => {
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });

    await new Promise((r) => setTimeout(r, 5));
    updatePricingRule(rule.id, { base_rate: 200, surcharge: 30 });

    const active = getActiveRule("cleaning", "z1");
    expect(active!.base_rate).toBe(200);
    expect(active!.surcharge).toBe(30);
  });
});

describe("temporal isolation", () => {
  it("jobs created before an update retain the old price", async () => {
    // Store initial rule
    const rule = storePricingRule({ service_type: "cleaning", zone_id: "z1", base_rate: 100, tax_rate: 0.18, surcharge: 10 });

    // Capture the price at job creation time (before update)
    const jobCreatedAt = new Date();
    const priceAtJobCreation = computeTotal(getActiveRule("cleaning", "z1", jobCreatedAt)!);

    await new Promise((r) => setTimeout(r, 5));

    // Admin updates the rule
    updatePricingRule(rule.id, { base_rate: 200, surcharge: 50 });

    // Price for the old job (queried at its creation time) should be unchanged
    const oldJobPrice = computeTotal(getActiveRule("cleaning", "z1", jobCreatedAt)!);
    expect(oldJobPrice).toBeCloseTo(priceAtJobCreation, 5);
    expect(oldJobPrice).toBeCloseTo(128, 5); // 100 * 1.18 + 10

    // New jobs (queried now) get the updated price
    const newJobPrice = computeTotal(getActiveRule("cleaning", "z1")!);
    expect(newJobPrice).toBeCloseTo(286, 5); // 200 * 1.18 + 50
  });

  it("multiple updates: each job gets the price active at its creation time", async () => {
    const rule = storePricingRule({ service_type: "waste", zone_id: "z2", base_rate: 50, tax_rate: 0.1, surcharge: 5 });
    // price1 = 50 * 1.1 + 5 = 60

    const t1 = new Date();
    const price1 = computeTotal(getActiveRule("waste", "z2", t1)!);
    expect(price1).toBeCloseTo(60, 5);

    await new Promise((r) => setTimeout(r, 5));
    updatePricingRule(rule.id, { base_rate: 80, surcharge: 0 });
    // price2 = 80 * 1.1 + 0 = 88

    const t2 = new Date();
    const price2 = computeTotal(getActiveRule("waste", "z2", t2)!);
    expect(price2).toBeCloseTo(88, 5);

    await new Promise((r) => setTimeout(r, 5));
    updatePricingRule(rule.id, { base_rate: 120, tax_rate: 0.05, surcharge: 10 });
    // price3 = 120 * 1.05 + 10 = 136

    const t3 = new Date();
    const price3 = computeTotal(getActiveRule("waste", "z2", t3)!);
    expect(price3).toBeCloseTo(136, 5);

    // Verify temporal isolation: t1 still sees price1
    expect(computeTotal(getActiveRule("waste", "z2", t1)!)).toBeCloseTo(60, 5);
    // t2 still sees price2
    expect(computeTotal(getActiveRule("waste", "z2", t2)!)).toBeCloseTo(88, 5);
  });
});
