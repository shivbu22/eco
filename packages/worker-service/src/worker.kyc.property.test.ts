// Feature: ecomins-platform, Property: KYC state transition validity

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import {
  createWorker,
  submitKyc,
  reviewKyc,
  _clearWorkerStore,
  _clearKycStore,
} from "./worker.js";

/**
 * Validates: Requirements 7.4, 7.5
 *
 * Property: KYC approval/rejection state transitions
 *
 * For any KYC submission:
 * - After approval, the worker's kyc_status must be "verified" and the
 *   submission status must be "approved".
 * - After rejection, the worker's kyc_status must be "rejected" and the
 *   submission must have a non-empty rejection_reason.
 */

// Arbitrary for non-empty trimmed strings (names, phones, zone_ids, skills, reasons)
const nonEmptyStringArb = fc
  .string({ minLength: 1, maxLength: 30 })
  .filter((s) => s.trim().length > 0)
  .map((s) => s.trim());

const phoneArb = fc
  .tuple(
    fc.integer({ min: 1, max: 9 }),
    fc.stringOf(fc.constantFrom("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"), {
      minLength: 6,
      maxLength: 12,
    })
  )
  .map(([first, rest]) => `+${first}${rest}`);

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

const rejectionReasonArb = fc
  .string({ minLength: 1, maxLength: 100 })
  .filter((s) => s.trim().length > 0)
  .map((s) => s.trim());

beforeEach(() => {
  _clearWorkerStore();
  _clearKycStore();
});

describe("Property: KYC state transition validity", () => {
  it("after approval, kyc_status is 'verified' and submission status is 'approved'", () => {
    // Validates: Requirements 7.4
    fc.assert(
      fc.property(
        nonEmptyStringArb,
        phoneArb,
        zoneIdArb,
        skillsArb,
        (name, phone, zone_id, skills) => {
          _clearWorkerStore();
          _clearKycStore();

          // Create worker
          const createResult = createWorker({ name, phone, zone_id, skills });
          if (!createResult.success) return false;
          const workerId = createResult.worker.id;

          // Submit KYC
          const kycResult = submitKyc(workerId, {
            id_document_url: "https://example.com/id.jpg",
            selfie_url: "https://example.com/selfie.jpg",
          });
          if (!kycResult.success) return false;

          // Approve KYC
          const reviewResult = reviewKyc(workerId, {
            approved: true,
            reviewed_by: "admin-1",
          });
          if (!reviewResult.success) return false;

          // Assert: worker kyc_status is "verified"
          if (reviewResult.worker.kyc_status !== "verified") return false;
          // Assert: submission status is "approved"
          if (reviewResult.submission.status !== "approved") return false;

          return true;
        }
      ),
      { numRuns: 20 }
    );
  });

  it("after rejection, kyc_status is 'rejected' and submission has a non-empty rejection_reason", () => {
    // Validates: Requirements 7.5
    fc.assert(
      fc.property(
        nonEmptyStringArb,
        phoneArb,
        zoneIdArb,
        skillsArb,
        rejectionReasonArb,
        (name, phone, zone_id, skills, reason) => {
          _clearWorkerStore();
          _clearKycStore();

          // Create worker
          const createResult = createWorker({ name, phone, zone_id, skills });
          if (!createResult.success) return false;
          const workerId = createResult.worker.id;

          // Submit KYC
          const kycResult = submitKyc(workerId, {
            id_document_url: "https://example.com/id.jpg",
            selfie_url: "https://example.com/selfie.jpg",
          });
          if (!kycResult.success) return false;

          // Reject KYC with a reason
          const reviewResult = reviewKyc(workerId, {
            approved: false,
            reason,
            reviewed_by: "admin-1",
          });
          if (!reviewResult.success) return false;

          // Assert: worker kyc_status is "rejected"
          if (reviewResult.worker.kyc_status !== "rejected") return false;
          // Assert: submission status is "rejected"
          if (reviewResult.submission.status !== "rejected") return false;
          // Assert: rejection_reason is non-empty
          if (
            !reviewResult.submission.rejection_reason ||
            reviewResult.submission.rejection_reason.trim().length === 0
          ) {
            return false;
          }

          return true;
        }
      ),
      { numRuns: 20 }
    );
  });

  it("rejection without a reason is rejected — the transition does not occur", () => {
    // Validates: Requirements 7.5 (reason is required on rejection)
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

          submitKyc(workerId, {
            id_document_url: "https://example.com/id.jpg",
            selfie_url: "https://example.com/selfie.jpg",
          });

          // Attempt rejection with no reason — must fail
          const reviewResult = reviewKyc(workerId, { approved: false });
          if (reviewResult.success) return false;
          if (reviewResult.status !== 400) return false;

          return true;
        }
      ),
      { numRuns: 20 }
    );
  });
});
