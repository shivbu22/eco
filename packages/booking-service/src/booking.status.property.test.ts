// Feature: ecomins-platform, Property: New jobs always start as pending

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { createJob, _clearJobStore } from "./booking.js";

/**
 * Validates: Requirements 3.6
 *
 * Property: Job creation status invariant
 *
 * For any valid booking input (random service_type, location lat/lng/address,
 * zone_id, customer_id, price), the created Job record must always have
 * status "pending".
 */

const nonEmptyStringArb = fc
  .string({ minLength: 1, maxLength: 40 })
  .filter((s) => s.trim().length > 0)
  .map((s) => s.trim());

const latArb = fc.double({ min: -90, max: 90, noNaN: true });
const lngArb = fc.double({ min: -180, max: 180, noNaN: true });

const locationArb = fc.record({
  lat: latArb,
  lng: lngArb,
  address: nonEmptyStringArb,
});

const priceArb = fc.double({ min: 0, max: 100_000, noNaN: true });

const createJobInputArb = fc.record({
  service_type: nonEmptyStringArb,
  location: locationArb,
  zone_id: nonEmptyStringArb,
  customer_id: nonEmptyStringArb,
  price: priceArb,
});

beforeEach(() => {
  _clearJobStore();
});

describe("Property: New jobs always start as pending", () => {
  it("any valid booking input produces a job with status 'pending'", () => {
    // Validates: Requirements 3.6
    fc.assert(
      fc.property(createJobInputArb, (input) => {
        _clearJobStore();

        const result = createJob(input);

        // The call must succeed for valid inputs
        if (!result.success) return false;

        // The status must always be "pending"
        return result.job.status === "pending";
      }),
      { numRuns: 100 }
    );
  });
});
