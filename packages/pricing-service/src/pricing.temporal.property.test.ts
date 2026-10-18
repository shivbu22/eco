// Feature: ecomins-platform, Property 8: Pricing rule temporal isolation

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import {
  computeTotal,
  getActiveRule,
  _clearPricingStore,
  _getPricingStore,
} from "./pricing.js";
import type { PricingRule } from "@ecomins/shared";
import { randomUUID } from "crypto";

/**
 * Validates: Requirements 13.3
 *
 * Property 8: Pricing rule temporal isolation
 *
 * For any pricing rule update, jobs created before the update time should
 * retain their original price, and jobs created after the update time should
 * use the new price.
 */

// Helper: insert a rule directly with a controlled timestamp
function insertRule(
  service_type: string,
  zone_id: string,
  base_rate: number,
  tax_rate: number,
  surcharge: number,
  effective_from: Date
): PricingRule {
  const rule: PricingRule = {
    id: randomUUID(),
    service_type,
    zone_id,
    base_rate,
    tax_rate,
    surcharge,
    effective_from: effective_from.toISOString(),
  };
  _getPricingStore().set(rule.id, rule);
  return rule;
}

// Arbitraries
const rateArb = fc.float({ min: 0, max: 500, noNaN: true, noDefaultInfinity: true });
const taxArb = fc.float({ min: 0, max: 0.5, noNaN: true, noDefaultInfinity: true });
const surchargeArb = fc.float({ min: 0, max: 100, noNaN: true, noDefaultInfinity: true });

const pricingParamsArb = fc.record({
  base_rate: rateArb,
  tax_rate: taxArb,
  surcharge: surchargeArb,
});

const serviceZoneArb = fc.record({
  service_type: fc.constantFrom("cleaning", "recycling", "waste", "logistics", "b2b"),
  zone_id: fc.constantFrom("zone-1", "zone-2", "zone-3"),
});

// Arbitrary for a base epoch (ms) — use a fixed range to keep timestamps reasonable
const epochArb = fc.integer({ min: 1_000_000, max: 2_000_000_000 });

beforeEach(() => {
  _clearPricingStore();
});

describe("Property 8: Pricing rule temporal isolation", () => {
  it("jobs created before a rule update retain the original price", () => {
    // Validates: Requirements 13.3
    fc.assert(
      fc.property(
        serviceZoneArb,
        pricingParamsArb,
        pricingParamsArb,
        epochArb,
        (serviceZone, oldParams, newParams, baseEpoch) => {
          _clearPricingStore();

          const { service_type, zone_id } = serviceZone;

          // t0: original rule becomes effective
          const t0 = new Date(baseEpoch);
          // t1: job is created (100ms after original rule)
          const t1 = new Date(baseEpoch + 100);
          // t2: rule is updated (200ms after original rule, strictly after t1)
          const t2 = new Date(baseEpoch + 200);

          // Insert original rule at t0
          insertRule(service_type, zone_id, oldParams.base_rate, oldParams.tax_rate, oldParams.surcharge, t0);

          // Insert updated rule at t2
          insertRule(service_type, zone_id, newParams.base_rate, newParams.tax_rate, newParams.surcharge, t2);

          // Job created at t1 (before update) should see old rule
          const ruleAtT1 = getActiveRule(service_type, zone_id, t1);
          if (!ruleAtT1) return false;

          const priceAtT1 = computeTotal(ruleAtT1);
          const expectedOldPrice =
            oldParams.base_rate * (1 + oldParams.tax_rate) + oldParams.surcharge;

          return Math.abs(priceAtT1 - expectedOldPrice) < 1e-3;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("jobs created after a rule update use the new price", () => {
    // Validates: Requirements 13.3
    fc.assert(
      fc.property(
        serviceZoneArb,
        pricingParamsArb,
        pricingParamsArb,
        epochArb,
        (serviceZone, oldParams, newParams, baseEpoch) => {
          _clearPricingStore();

          const { service_type, zone_id } = serviceZone;

          // t0: original rule
          const t0 = new Date(baseEpoch);
          // t2: updated rule
          const t2 = new Date(baseEpoch + 200);
          // t3: job created after update
          const t3 = new Date(baseEpoch + 300);

          insertRule(service_type, zone_id, oldParams.base_rate, oldParams.tax_rate, oldParams.surcharge, t0);
          insertRule(service_type, zone_id, newParams.base_rate, newParams.tax_rate, newParams.surcharge, t2);

          // Job created at t3 (after update) should see new rule
          const ruleAtT3 = getActiveRule(service_type, zone_id, t3);
          if (!ruleAtT3) return false;

          const priceAtT3 = computeTotal(ruleAtT3);
          const expectedNewPrice =
            newParams.base_rate * (1 + newParams.tax_rate) + newParams.surcharge;

          return Math.abs(priceAtT3 - expectedNewPrice) < 1e-3;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("temporal isolation holds across multiple rule updates", () => {
    // Validates: Requirements 13.3
    // For any sequence of rule updates, each job sees the price active at its creation time.
    fc.assert(
      fc.property(
        serviceZoneArb,
        pricingParamsArb,
        pricingParamsArb,
        pricingParamsArb,
        epochArb,
        (serviceZone, params1, params2, params3, baseEpoch) => {
          _clearPricingStore();

          const { service_type, zone_id } = serviceZone;

          // Three rules at t=0, t=200, t=400
          const t0 = new Date(baseEpoch);
          const t2 = new Date(baseEpoch + 200);
          const t4 = new Date(baseEpoch + 400);

          // Jobs created at t=100, t=300, t=500
          const jobT1 = new Date(baseEpoch + 100);
          const jobT3 = new Date(baseEpoch + 300);
          const jobT5 = new Date(baseEpoch + 500);

          insertRule(service_type, zone_id, params1.base_rate, params1.tax_rate, params1.surcharge, t0);
          insertRule(service_type, zone_id, params2.base_rate, params2.tax_rate, params2.surcharge, t2);
          insertRule(service_type, zone_id, params3.base_rate, params3.tax_rate, params3.surcharge, t4);

          const rule1 = getActiveRule(service_type, zone_id, jobT1);
          const rule2 = getActiveRule(service_type, zone_id, jobT3);
          const rule3 = getActiveRule(service_type, zone_id, jobT5);

          if (!rule1 || !rule2 || !rule3) return false;

          const price1 = computeTotal(rule1);
          const price2 = computeTotal(rule2);
          const price3 = computeTotal(rule3);

          const expected1 = params1.base_rate * (1 + params1.tax_rate) + params1.surcharge;
          const expected2 = params2.base_rate * (1 + params2.tax_rate) + params2.surcharge;
          const expected3 = params3.base_rate * (1 + params3.tax_rate) + params3.surcharge;

          const tol = 1e-3;
          return (
            Math.abs(price1 - expected1) < tol &&
            Math.abs(price2 - expected2) < tol &&
            Math.abs(price3 - expected3) < tol
          );
        }
      ),
      { numRuns: 100 }
    );
  });
});
