// Feature: ecomins-platform, Property 4: Matching only assigns eligible workers

/**
 * Validates: Requirements 4.1, 7.6
 *
 * Property 4: Matching only assigns verified, available workers
 *
 * For any job and any pool of workers with mixed kyc_status and availability
 * values, the assigned worker must always have:
 *   - kyc_status === "verified"
 *   - availability === true
 *   - skills includes the job's service_type
 *
 * If no eligible workers exist, matchJob must return null.
 */

import { describe, it } from "vitest";
import * as fc from "fast-check";
import { matchJob, filterEligibleWorkers, WorkerWithLocation } from "./matching.js";

// ── Arbitraries ───────────────────────────────────────────────────────────────

const kycStatusArb = fc.constantFrom(
  "pending" as const,
  "verified" as const,
  "rejected" as const
);

const serviceTypeArb = fc.constantFrom(
  "cleaning",
  "recycling",
  "waste_management",
  "logistics",
  "b2b"
);

const skillArb = fc.constantFrom(
  "cleaning",
  "recycling",
  "waste_management",
  "logistics",
  "b2b"
);

const skillsArb = fc
  .array(skillArb, { minLength: 1, maxLength: 4 })
  .map((arr) => [...new Set(arr)]);

// Latitude: -90 to 90, Longitude: -180 to 180
const latArb = fc.float({ min: -89, max: 89, noNaN: true });
const lngArb = fc.float({ min: -179, max: 179, noNaN: true });

const zoneIdArb = fc.integer({ min: 1, max: 10 }).map((n) => `zone-${n}`);

const workerArb = fc.record({
  id: fc.uuid(),
  zone_id: zoneIdArb,
  skills: skillsArb,
  availability: fc.boolean(),
  kyc_status: kycStatusArb,
  rating: fc.float({ min: 0, max: 5, noNaN: true }),
  total_jobs: fc.integer({ min: 0, max: 1000 }),
  lat: latArb,
  lng: lngArb,
}) satisfies fc.Arbitrary<WorkerWithLocation>;

const workerPoolArb = fc.array(workerArb, { minLength: 0, maxLength: 20 });

// Job arbitrary — zone_id drawn from the same pool as workers for realistic matching
const jobArb = (serviceType: string, zoneId: string) =>
  fc.record({
    id: fc.uuid(),
    customer_id: fc.uuid(),
    worker_id: fc.constant(null),
    service_type: fc.constant(serviceType),
    status: fc.constant("pending" as const),
    location: fc.record({
      lat: latArb,
      lng: lngArb,
      address: fc.string({ minLength: 1, maxLength: 50 }),
    }),
    zone_id: fc.constant(zoneId),
    scheduled_time: fc.constant(null),
    before_photo_url: fc.constant(null),
    after_photo_url: fc.constant(null),
    price: fc.float({ min: 1, max: 10000, noNaN: true }),
    created_at: fc.constant(new Date().toISOString()),
    updated_at: fc.constant(new Date().toISOString()),
  });

// ── Tests ─────────────────────────────────────────────────────────────────────

describe("Property 4: Matching only assigns eligible workers", () => {
  it("assigned worker always has kyc_status=verified, availability=true, and required skill", () => {
    // Validates: Requirements 4.1, 7.6
    fc.assert(
      fc.property(
        serviceTypeArb,
        zoneIdArb,
        workerPoolArb,
        latArb,
        lngArb,
        (serviceType, zoneId, workers, jobLat, jobLng) => {
          const job = {
            id: "job-1",
            customer_id: "cust-1",
            worker_id: null,
            service_type: serviceType,
            status: "pending" as const,
            location: { lat: jobLat, lng: jobLng, address: "Test St" },
            zone_id: zoneId,
            scheduled_time: null,
            before_photo_url: null,
            after_photo_url: null,
            price: 100,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          };

          // Build a minimal zone list so matchJob can resolve the primary zone
          const zones = [
            {
              id: zoneId,
              name: `Zone ${zoneId}`,
              center_lat: jobLat,
              center_lng: jobLng,
              radius_meters: 2000,
              adjacent_zone_ids: [],
            },
          ];

          const assigned = matchJob(job, workers, zones);

          if (assigned === null) {
            // Null is only valid when there are no eligible workers
            const eligible = filterEligibleWorkers(workers, job);
            const inZone = eligible.filter((w) => w.zone_id === zoneId);
            // With no adjacent zones, eligible workers must all be outside the zone
            return inZone.length === 0;
          }

          // If a worker was assigned, it must satisfy all eligibility criteria
          return (
            assigned.kyc_status === "verified" &&
            assigned.availability === true &&
            assigned.skills.includes(serviceType)
          );
        }
      ),
      { numRuns: 100 }
    );
  });

  it("returns null when no workers in the pool are eligible", () => {
    // Validates: Requirements 4.1, 7.6
    fc.assert(
      fc.property(
        serviceTypeArb,
        zoneIdArb,
        // Pool of workers that are all ineligible (not verified, not available, or missing skill)
        fc.array(
          fc.oneof(
            // Not verified
            workerArb.map((w) => ({ ...w, kyc_status: "pending" as const })),
            workerArb.map((w) => ({ ...w, kyc_status: "rejected" as const })),
            // Not available
            workerArb.map((w) => ({ ...w, availability: false })),
            // Missing required skill — give them only skills that are NOT the job's service_type
            fc.record({
              id: fc.uuid(),
              zone_id: zoneIdArb,
              skills: fc.constant(["other_skill_xyz"]),
              availability: fc.constant(true),
              kyc_status: fc.constant("verified" as const),
              rating: fc.float({ min: 0, max: 5, noNaN: true }),
              total_jobs: fc.integer({ min: 0, max: 100 }),
              lat: latArb,
              lng: lngArb,
            })
          ),
          { minLength: 1, maxLength: 10 }
        ),
        (serviceType, zoneId, ineligibleWorkers) => {
          const job = {
            id: "job-2",
            customer_id: "cust-2",
            worker_id: null,
            service_type: serviceType,
            status: "pending" as const,
            location: { lat: 0, lng: 0, address: "Test St" },
            zone_id: zoneId,
            scheduled_time: null,
            before_photo_url: null,
            after_photo_url: null,
            price: 100,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          };

          const zones = [
            {
              id: zoneId,
              name: `Zone ${zoneId}`,
              center_lat: 0,
              center_lng: 0,
              radius_meters: 2000,
              adjacent_zone_ids: [],
            },
          ];

          // Assign all ineligible workers to the job's zone so zone filtering isn't the cause
          const workersInZone = ineligibleWorkers.map((w) => ({
            ...w,
            zone_id: zoneId,
          }));

          const assigned = matchJob(job, workersInZone, zones);
          return assigned === null;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("filterEligibleWorkers never returns a worker with kyc_status !== verified", () => {
    // Validates: Requirements 7.6
    fc.assert(
      fc.property(workerPoolArb, serviceTypeArb, (workers, serviceType) => {
        const job = {
          id: "job-3",
          customer_id: "cust-3",
          worker_id: null,
          service_type: serviceType,
          status: "pending" as const,
          location: { lat: 0, lng: 0, address: "Test St" },
          zone_id: "zone-1",
          scheduled_time: null,
          before_photo_url: null,
          after_photo_url: null,
          price: 100,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };

        const eligible = filterEligibleWorkers(workers, job);

        return eligible.every(
          (w) =>
            w.kyc_status === "verified" &&
            w.availability === true &&
            w.skills.includes(serviceType)
        );
      }),
      { numRuns: 100 }
    );
  });
});
