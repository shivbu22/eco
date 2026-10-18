// Feature: ecomins-platform, Property: B2B contract validation

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { createContract, _clearContractStore } from "./contracts.js";

/**
 * Validates: Requirements 17.1
 *
 * Property: B2B contract requires all mandatory fields
 *
 * For any contract creation request missing any mandatory field
 * (client_name, service_scope, zone_id, start_date, end_date,
 * monthly_rate, recurrence_schedule), the request must be rejected
 * with status 400.
 */

const MANDATORY_FIELDS = [
  "client_name",
  "service_scope",
  "zone_id",
  "start_date",
  "end_date",
  "monthly_rate",
  "recurrence_schedule",
] as const;

type MandatoryField = (typeof MANDATORY_FIELDS)[number];

// Arbitrary for non-empty trimmed strings
const nonEmptyStringArb = fc
  .string({ minLength: 1, maxLength: 40 })
  .filter((s) => s.trim().length > 0)
  .map((s) => s.trim());

// Arbitrary for a positive monthly rate
const monthlyRateArb = fc.float({ min: 1, max: 100_000, noNaN: true });

// Arbitrary for a valid ISO date string (YYYY-MM-DD)
const dateStringArb = fc
  .integer({ min: 2020, max: 2030 })
  .chain((year) =>
    fc
      .integer({ min: 1, max: 12 })
      .map((month) => `${year}-${String(month).padStart(2, "0")}-01`)
  );

// Arbitrary for a valid cron expression (simple weekly patterns)
const cronArb = fc
  .tuple(
    fc.integer({ min: 0, max: 59 }),
    fc.integer({ min: 0, max: 23 }),
    fc.integer({ min: 0, max: 6 })
  )
  .map(([min, hour, dow]) => `${min} ${hour} * * ${dow}`);

// A fully valid contract input
const validInputArb = fc.record({
  client_name: nonEmptyStringArb,
  service_scope: nonEmptyStringArb,
  zone_id: nonEmptyStringArb,
  start_date: dateStringArb,
  end_date: dateStringArb,
  monthly_rate: monthlyRateArb,
  recurrence_schedule: cronArb,
});

beforeEach(() => {
  _clearContractStore();
});

describe("Property: B2B contract requires all mandatory fields", () => {
  // Test each string field individually
  for (const field of MANDATORY_FIELDS) {
    if (field === "monthly_rate") continue; // handled separately below

    it(`returns 400 when '${field}' is missing or blank`, () => {
      // Validates: Requirements 17.1
      fc.assert(
        fc.property(
          validInputArb,
          fc.constantFrom("", "   ", "\t", "\n"),
          (validInput, blankValue) => {
            _clearContractStore();

            const input = { ...validInput, [field as MandatoryField]: blankValue };
            const result = createContract(input);

            return result.success === false && result.status === 400;
          }
        ),
        { numRuns: 100 }
      );
    });
  }

  it("returns 400 when 'monthly_rate' is NaN", () => {
    // Validates: Requirements 17.1
    fc.assert(
      fc.property(validInputArb, (validInput) => {
        _clearContractStore();

        const input = { ...validInput, monthly_rate: NaN };
        const result = createContract(input);

        return result.success === false && result.status === 400;
      }),
      { numRuns: 100 }
    );
  });

  it("accepts a contract when all mandatory fields are present and valid", () => {
    // Validates: Requirements 17.1 (positive case — valid input must succeed)
    fc.assert(
      fc.property(validInputArb, (validInput) => {
        _clearContractStore();

        const result = createContract(validInput);

        return result.success === true;
      }),
      { numRuns: 100 }
    );
  });
});
