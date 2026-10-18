// Feature: ecomins-platform, Property 7: Earnings net amount invariant

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { calculateEarnings, _resetStore } from "./earnings";

/**
 * Validates: Requirements 9.1, 9.5
 *
 * For any job price (>= 0) and commission rate in [0, 1),
 * net_amount = price * (1 - commission_rate) and net_amount >= 0.
 */

beforeEach(() => {
  _resetStore();
});

describe("Property 7: Earnings net amount invariant", () => {
  it("net_amount equals gross * (1 - commission_rate) for any valid price and commission rate", () => {
    fc.assert(
      fc.property(
        fc.double({ min: 0, max: 1_000_000, noNaN: true }),   // job price >= 0
        fc.double({ min: 0, max: 0.9999, noNaN: true }),       // commission rate in [0, 1)
        (price, commissionRate) => {
          _resetStore();
          const record = calculateEarnings("worker-1", "job-1", price, commissionRate);
          const expected = price * (1 - commissionRate);

          // net_amount matches the formula
          const diff = Math.abs(record.net_amount - expected);
          const tolerance = Math.max(Math.abs(expected) * 1e-5, 1e-9);

          return diff <= tolerance && record.net_amount >= 0;
        }
      ),
      { numRuns: 100 }
    );
  });
});
