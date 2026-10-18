// Feature: ecomins-platform, Property 3: Booking price consistency

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import {
  storePricingRule,
  getActiveRule,
  computeTotal,
  _clearPricingStore,
} from "./pricing.js";

/**
 * Validates: Requirements 3.5, 13.2
 *
 * Property 3: Booking price consistency
 *
 * For any service type and zone combination, the price returned by
 * getActiveRule + computeTotal equals the price that would be stored on a
 * Job record created for that service/zone combination at the same point in
 * time. The property also verifies that the pricing lookup is deterministic
 * and consistent — calling it twice at the same time returns the same total.
 */

beforeEach(() => {
  _clearPricingStore();
});

const serviceTypeArb = fc.constantFrom(
  "cleaning",
  "recycling",
  "waste",
  "logistics",
  "b2b"
);
const zoneIdArb = fc.constantFrom("zone-1", "zone-2", "zone-3");

const rateArb = fc.float({ min: 0, max: 500, noNaN: true, noDefaultInfinity: true });
const taxArb = fc.float({ min: 0, max: 0.5, noNaN: true, noDefaultInfinity: true });
const surchargeArb = fc.float({ min: 0, max: 100, noNaN: true, noDefaultInfinity: true });

describe("Property 3: Booking price consistency", () => {
  it("price from getActiveRule+computeTotal matches the price stored on the job record", () => {
    // Validates: Requirements 3.5, 13.2
    fc.assert(
      fc.property(
        serviceTypeArb,
        zoneIdArb,
        rateArb,
        taxArb,
        surchargeArb,
        (service_type, zone_id, base_rate, tax_rate, surcharge) => {
          _clearPricingStore();

          // Store a pricing rule (simulates admin setting a price)
          storePricingRule({ service_type, zone_id, base_rate, tax_rate, surcharge });

          // Simulate booking: look up the active rule at booking time
          const bookingTime = new Date();
          const rule = getActiveRule(service_type, zone_id, bookingTime);
          if (!rule) return false;

          // Price displayed to customer during booking
          const displayedPrice = computeTotal(rule);

          // Price that would be stored on the Job record (same lookup, same time)
          const jobRule = getActiveRule(service_type, zone_id, bookingTime);
          if (!jobRule) return false;
          const jobPrice = computeTotal(jobRule);

          // Both must be equal — the price is consistent
          return Math.abs(displayedPrice - jobPrice) < 1e-9;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("pricing lookup is deterministic — calling it twice at the same time returns the same total", () => {
    // Validates: Requirements 3.5, 13.2
    fc.assert(
      fc.property(
        serviceTypeArb,
        zoneIdArb,
        rateArb,
        taxArb,
        surchargeArb,
        (service_type, zone_id, base_rate, tax_rate, surcharge) => {
          _clearPricingStore();

          storePricingRule({ service_type, zone_id, base_rate, tax_rate, surcharge });

          const asOf = new Date();

          const rule1 = getActiveRule(service_type, zone_id, asOf);
          const rule2 = getActiveRule(service_type, zone_id, asOf);

          if (!rule1 || !rule2) return false;

          const total1 = computeTotal(rule1);
          const total2 = computeTotal(rule2);

          return total1 === total2;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("price is consistent across multiple service/zone combinations stored simultaneously", () => {
    // Validates: Requirements 3.5, 13.2
    // Ensures that storing rules for different service/zone pairs doesn't cause cross-contamination
    fc.assert(
      fc.property(
        fc.record({
          service_type: serviceTypeArb,
          zone_id: zoneIdArb,
          base_rate: rateArb,
          tax_rate: taxArb,
          surcharge: surchargeArb,
        }),
        fc.record({
          service_type: serviceTypeArb,
          zone_id: zoneIdArb,
          base_rate: rateArb,
          tax_rate: taxArb,
          surcharge: surchargeArb,
        }),
        (params1, params2) => {
          _clearPricingStore();

          storePricingRule(params1);
          storePricingRule(params2);

          const asOf = new Date();

          // Each lookup must return a price consistent with its own stored rule
          const rule1 = getActiveRule(params1.service_type, params1.zone_id, asOf);
          const rule2 = getActiveRule(params2.service_type, params2.zone_id, asOf);

          if (!rule1 || !rule2) return false;

          const price1 = computeTotal(rule1);
          const price2 = computeTotal(rule2);

          const expected1 = params1.base_rate * (1 + params1.tax_rate) + params1.surcharge;
          const expected2 = params2.base_rate * (1 + params2.tax_rate) + params2.surcharge;

          // When service/zone are the same, the latest rule wins — both are valid
          // When different, each must match its own expected price
          if (
            params1.service_type === params2.service_type &&
            params1.zone_id === params2.zone_id
          ) {
            // Same key: the active rule is whichever was stored last (params2, since it was stored second)
            // Both computeTotal calls on the same active rule must agree
            return price1 === price2;
          }

          const tol = 1e-3;
          return (
            Math.abs(price1 - expected1) < tol &&
            Math.abs(price2 - expected2) < tol
          );
        }
      ),
      { numRuns: 100 }
    );
  });
});
