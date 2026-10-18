// Feature: ecomins-platform, Property 9: Eco Points balance non-negative invariant

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { awardPoints, redeemPoints, getAccount, _clearStore } from "./rewards";

/**
 * Validates: Requirements 15.4, 15.5
 *
 * For any sequence of award and redemption operations on a random starting balance,
 * the Customer's Eco Points balance should never go negative.
 */

beforeEach(() => {
  _clearStore();
});

describe("Property 9: Eco Points balance non-negative invariant", () => {
  it("balance never goes negative after any sequence of award and redeem operations", () => {
    // Operation: either award some points or attempt to redeem some points
    const operationArb = fc.oneof(
      fc.record({ type: fc.constant("award" as const), points: fc.integer({ min: 1, max: 1000 }) }),
      fc.record({ type: fc.constant("redeem" as const), points: fc.integer({ min: 1, max: 1000 }) })
    );

    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 5000 }),   // initial balance seeded via award
        fc.array(operationArb, { minLength: 1, maxLength: 50 }),
        (initialBalance, operations) => {
          _clearStore();
          const customerId = "customer-test";

          // Seed the initial balance
          if (initialBalance > 0) {
            awardPoints(customerId, initialBalance, "seed-job");
          }

          // Apply each operation; redemptions that would go negative are rejected by the service
          for (const op of operations) {
            if (op.type === "award") {
              awardPoints(customerId, op.points, `job-${Math.random()}`);
            } else {
              try {
                redeemPoints(customerId, op.points);
              } catch {
                // Insufficient balance — rejection is expected and correct per Req 15.5
              }
            }

            // Invariant: balance must never be negative after any operation
            const account = getAccount(customerId);
            if (account.points_balance < 0) {
              return false;
            }
          }

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });
});
