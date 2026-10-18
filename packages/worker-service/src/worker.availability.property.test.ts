// Feature: ecomins-platform, Property 11: Availability toggle immediate effect

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import {
  createWorker,
  updateAvailability,
  getWorker,
  _clearWorkerStore,
  _clearKycStore,
} from "./worker.js";

/**
 * Validates: Requirements 8.5, 8.6
 *
 * Property 11: Availability toggle immediate effect
 *
 * For any Worker:
 * - Toggling availability to false then back to true restores the original
 *   available state (round-trip).
 * - After toggling to false, the worker's availability is false (not in
 *   eligible pool — simulated by checking availability === false).
 * - After toggling back to true, the worker's availability is true again.
 */

const nonEmptyStringArb = fc
  .string({ minLength: 1, maxLength: 30 })
  .filter((s) => s.trim().length > 0)
  .map((s) => s.trim());

const phoneArb = fc
  .tuple(
    fc.integer({ min: 1, max: 9 }),
    fc.integer({ min: 1000000, max: 9999999999 })
  )
  .map(([prefix, digits]) => `+${prefix}${digits}`);

const zoneIdArb = fc
  .integer({ min: 1, max: 100 })
  .map((n) => `zone-${n}`);

const skillArb = fc.constantFrom(
  "cleaning",
  "recycling",
  "waste_management",
  "logistics",
  "b2b"
);

const skillsArb = fc
  .array(skillArb, { minLength: 1, maxLength: 3 })
  .map((arr) => [...new Set(arr)]);

beforeEach(() => {
  _clearWorkerStore();
  _clearKycStore();
});

describe("Property 11: Availability toggle immediate effect", () => {
  it("toggling availability false then true restores original available state (round-trip)", () => {
    // Validates: Requirements 8.5, 8.6
    fc.assert(
      fc.property(
        nonEmptyStringArb,
        phoneArb,
        zoneIdArb,
        skillsArb,
        (name, phone, zone_id, skills) => {
          _clearWorkerStore();
          _clearKycStore();

          // Create worker — starts with availability: true
          const createResult = createWorker({ name, phone, zone_id, skills });
          if (!createResult.success) return false;
          const workerId = createResult.worker.id;
          const originalAvailability = createResult.worker.availability;

          // Toggle to false
          const toggleOffResult = updateAvailability(workerId, false);
          if (!toggleOffResult.success) return false;

          // Verify immediately unavailable (Req 8.5)
          if (toggleOffResult.worker.availability !== false) return false;

          // Confirm via getWorker that the store reflects the change
          const afterOff = getWorker(workerId);
          if (!afterOff.success) return false;
          if (afterOff.worker.availability !== false) return false;

          // Toggle back to true
          const toggleOnResult = updateAvailability(workerId, true);
          if (!toggleOnResult.success) return false;

          // Verify immediately available again (Req 8.6)
          if (toggleOnResult.worker.availability !== true) return false;

          // Confirm round-trip: availability restored to original
          const afterOn = getWorker(workerId);
          if (!afterOn.success) return false;
          if (afterOn.worker.availability !== originalAvailability) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("after toggling to false, worker does not appear in eligible pool (availability === false)", () => {
    // Validates: Requirements 8.5
    fc.assert(
      fc.property(
        nonEmptyStringArb,
        phoneArb,
        zoneIdArb,
        skillsArb,
        (name, phone, zone_id, skills) => {
          _clearWorkerStore();
          _clearKycStore();

          const createResult = createWorker({ name, phone, zone_id, skills });
          if (!createResult.success) return false;
          const workerId = createResult.worker.id;

          // Toggle unavailable
          const toggleOffResult = updateAvailability(workerId, false);
          if (!toggleOffResult.success) return false;

          // Simulate eligible pool query: worker must NOT be eligible
          // (availability === false means excluded from matching)
          const workerState = getWorker(workerId);
          if (!workerState.success) return false;

          // The worker should be excluded from any eligible pool
          if (workerState.worker.availability !== false) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("after toggling back to true, worker is available again for job assignments", () => {
    // Validates: Requirements 8.6
    fc.assert(
      fc.property(
        nonEmptyStringArb,
        phoneArb,
        zoneIdArb,
        skillsArb,
        (name, phone, zone_id, skills) => {
          _clearWorkerStore();
          _clearKycStore();

          const createResult = createWorker({ name, phone, zone_id, skills });
          if (!createResult.success) return false;
          const workerId = createResult.worker.id;

          // Toggle off then on
          const offResult = updateAvailability(workerId, false);
          if (!offResult.success) return false;
          if (offResult.worker.availability !== false) return false;

          const onResult = updateAvailability(workerId, true);
          if (!onResult.success) return false;

          // Worker must be back in eligible pool
          if (onResult.worker.availability !== true) return false;

          const workerState = getWorker(workerId);
          if (!workerState.success) return false;
          if (workerState.worker.availability !== true) return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });
});
