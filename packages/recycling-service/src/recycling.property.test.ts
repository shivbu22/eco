// Feature: ecomins-platform, Property 10: Recycling payout calculation consistency

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { BUY_RATES, recordRecycling, _clearStore } from "./recycling";
import type { RecyclingRecord } from "@ecomins/shared";

/**
 * Validates: Requirements 18.4
 *
 * For any waste category and weight, assert:
 *   payout_amount = weight_kg * BUY_RATES[waste_category]
 */

beforeEach(() => {
  _clearStore();
});

describe("Property 10: Recycling payout calculation consistency", () => {
  it("payout_amount always equals weight_kg * BUY_RATES[waste_category]", () => {
    const wasteCategoryArb = fc.constantFrom(
      ...Object.keys(BUY_RATES) as RecyclingRecord["waste_category"][]
    );

    // Positive weights with reasonable precision (avoid floating-point noise)
    const weightArb = fc.double({ min: 0.01, max: 10000, noNaN: true, noDefaultInfinity: true });

    fc.assert(
      fc.property(
        wasteCategoryArb,
        weightArb,
        (wasteCategory, weightKg) => {
          _clearStore();
          const record = recordRecycling(
            `job-${Math.random()}`,
            "customer-1",
            wasteCategory,
            weightKg,
            "cash"
          );

          const expected = weightKg * BUY_RATES[wasteCategory];
          return record.payout_amount === expected;
        }
      ),
      { numRuns: 100 }
    );
  });
});
