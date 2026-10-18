// Feature: ecomins-platform, Property 6: Proof required before status transition

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import {
  createJob,
  assignJob,
  setEnRoute,
  startJob,
  completeJob,
  _clearJobStore,
} from "./booking.js";

/**
 * Validates: Requirements 6.1, 6.2, 6.4
 *
 * Property 6: Proof required before status transition
 *
 * - For any Job, calling startJob without a valid before_photo_url
 *   (null, undefined, empty string, or whitespace-only) must return status 400.
 * - For any Job in in_progress, calling completeJob without a valid
 *   after_photo_url must return status 400.
 */

// Arbitraries

const serviceTypeArb = fc.constantFrom(
  "cleaning",
  "recycling",
  "waste_management",
  "logistics",
  "b2b"
);

const locationArb = fc.record({
  lat: fc.float({ min: -90, max: 90, noNaN: true }),
  lng: fc.float({ min: -180, max: 180, noNaN: true }),
  address: fc
    .string({ minLength: 1, maxLength: 50 })
    .filter((s) => s.trim().length > 0)
    .map((s) => s.trim()),
});

const zoneIdArb = fc.integer({ min: 1, max: 100 }).map((n) => `zone-${n}`);

const customerIdArb = fc
  .integer({ min: 1, max: 1000 })
  .map((n) => `customer-${n}`);

const priceArb = fc.float({ min: 0, max: 10000, noNaN: true });

// Blank/missing photo values that should be rejected
const invalidPhotoArb = fc.oneof(
  fc.constant(null),
  fc.constant(undefined),
  fc.constant(""),
  // whitespace-only strings
  fc
    .string({ minLength: 1, maxLength: 10 })
    .filter((s) => s.trim().length === 0)
);

// Valid photo URL
const validPhotoArb = fc
  .string({ minLength: 1, maxLength: 100 })
  .filter((s) => s.trim().length > 0)
  .map((s) => `https://example.com/${s.trim()}.jpg`);

// Helper: create a job and return its id
function makeJobId(
  service_type: string,
  location: { lat: number; lng: number; address: string },
  zone_id: string,
  customer_id: string,
  price: number
): string {
  const result = createJob({ service_type, location, zone_id, customer_id, price });
  if (!result.success) throw new Error("createJob failed: " + result.message);
  return result.job.id;
}

beforeEach(() => {
  _clearJobStore();
});

describe("Property 6: Proof required before status transition", () => {
  it("startJob without before_photo_url always returns status 400", () => {
    // Validates: Requirements 6.1
    fc.assert(
      fc.property(
        serviceTypeArb,
        locationArb,
        zoneIdArb,
        customerIdArb,
        priceArb,
        invalidPhotoArb,
        (service_type, location, zone_id, customer_id, price, invalidPhoto) => {
          _clearJobStore();
          const jobId = makeJobId(service_type, location, zone_id, customer_id, price);

          const result = startJob(jobId, invalidPhoto as string | null | undefined);

          if (result.success) return false;
          if (result.status !== 400) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("startJob without before_photo_url returns 400 regardless of prior job state (pending, assigned, en_route)", () => {
    // Validates: Requirements 6.1
    // Tests all valid predecessor states for startJob
    const stateSetupArb = fc.constantFrom<"pending" | "assigned" | "en_route">(
      "pending",
      "assigned",
      "en_route"
    );

    fc.assert(
      fc.property(
        serviceTypeArb,
        locationArb,
        zoneIdArb,
        customerIdArb,
        priceArb,
        invalidPhotoArb,
        stateSetupArb,
        (service_type, location, zone_id, customer_id, price, invalidPhoto, state) => {
          _clearJobStore();
          const jobId = makeJobId(service_type, location, zone_id, customer_id, price);

          // Advance to the desired state
          if (state === "assigned" || state === "en_route") {
            assignJob(jobId, "worker-1");
          }
          if (state === "en_route") {
            setEnRoute(jobId);
          }

          const result = startJob(jobId, invalidPhoto as string | null | undefined);

          if (result.success) return false;
          if (result.status !== 400) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("completeJob without after_photo_url always returns status 400 when job is in_progress", () => {
    // Validates: Requirements 6.2, 6.4
    fc.assert(
      fc.property(
        serviceTypeArb,
        locationArb,
        zoneIdArb,
        customerIdArb,
        priceArb,
        validPhotoArb,
        invalidPhotoArb,
        (service_type, location, zone_id, customer_id, price, beforePhoto, invalidAfterPhoto) => {
          _clearJobStore();
          const jobId = makeJobId(service_type, location, zone_id, customer_id, price);

          // Advance to in_progress (requires a valid before photo)
          const startResult = startJob(jobId, beforePhoto);
          if (!startResult.success) return false;

          const result = completeJob(jobId, invalidAfterPhoto as string | null | undefined);

          if (result.success) return false;
          if (result.status !== 400) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });
});
