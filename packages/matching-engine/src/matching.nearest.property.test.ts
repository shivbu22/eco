// Feature: ecomins-platform, Property 5: Nearest worker assigned first

/**
 * Validates: Requirements 4.2
 *
 * Property 5: Nearest worker assigned first
 *
 * For any set of eligible workers at random locations, the worker with the
 * minimum Haversine distance to the job location must always be the one
 * returned by findNearestWorker.
 */

import { describe, it } from "vitest";
import * as fc from "fast-check";
import { findNearestWorker, haversineDistance, WorkerWithLocation } from "./matching.js";
import type { Worker } from "@ecomins/shared";

// ── Arbitraries ───────────────────────────────────────────────────────────────

const latArb = fc.float({ min: -89, max: 89, noNaN: true });
const lngArb = fc.float({ min: -179, max: 179, noNaN: true });

/** A minimal eligible worker with a geographic position */
const eligibleWorkerArb: fc.Arbitrary<WorkerWithLocation> = fc.record({
  id: fc.uuid(),
  zone_id: fc.constant("zone-1"),
  skills: fc.constant(["cleaning"]),
  availability: fc.constant(true),
  kyc_status: fc.constant("verified" as const),
  rating: fc.float({ min: 0, max: 5, noNaN: true }),
  total_jobs: fc.integer({ min: 0, max: 1000 }),
  lat: latArb,
  lng: lngArb,
});

/** A non-empty pool of eligible workers (1–20 workers) */
const workerPoolArb = fc.array(eligibleWorkerArb, { minLength: 1, maxLength: 20 });

// ── Tests ─────────────────────────────────────────────────────────────────────

describe("Property 5: Nearest worker assigned first", () => {
  it("findNearestWorker always returns the worker with minimum Haversine distance", () => {
    // Validates: Requirements 4.2
    fc.assert(
      fc.property(
        workerPoolArb,
        latArb,
        lngArb,
        (workers, jobLat, jobLng) => {
          const assigned = findNearestWorker(workers, jobLat, jobLng);

          // Pool is non-empty so a worker must always be returned
          if (assigned === null) return false;

          // Compute the minimum distance across all workers
          const minDistance = Math.min(
            ...workers.map((w) => haversineDistance(w.lat, w.lng, jobLat, jobLng))
          );

          const assignedDistance = haversineDistance(
            assigned.lat,
            assigned.lng,
            jobLat,
            jobLng
          );

          // The assigned worker's distance must equal the minimum distance
          return assignedDistance <= minDistance + Number.EPSILON;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("findNearestWorker returns null for an empty pool", () => {
    // Validates: Requirements 4.2 (edge case — no workers available)
    fc.assert(
      fc.property(latArb, lngArb, (jobLat, jobLng) => {
        return findNearestWorker([], jobLat, jobLng) === null;
      }),
      { numRuns: 100 }
    );
  });

  it("findNearestWorker returns the only worker when pool has exactly one worker", () => {
    // Validates: Requirements 4.2 (single-worker edge case)
    fc.assert(
      fc.property(eligibleWorkerArb, latArb, lngArb, (worker, jobLat, jobLng) => {
        const result = findNearestWorker([worker], jobLat, jobLng);
        return result !== null && result.id === worker.id;
      }),
      { numRuns: 100 }
    );
  });
});
