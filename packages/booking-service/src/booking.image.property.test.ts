// Feature: ecomins-platform, Property: Image format and size validation

import { describe, it } from "vitest";
import * as fc from "fast-check";
import { validateImage } from "./booking.js";

/**
 * Validates: Requirements 3.2, 3.3, 6.3
 *
 * Property: Image upload validation
 *
 * - For any file with invalid MIME type (not image/jpeg or image/png) or
 *   size > 10MB, the upload must be rejected with valid=false.
 * - For any valid JPEG/PNG with size ≤ 10MB, the upload must be accepted
 *   with valid=true.
 */

const MAX_SIZE = 10 * 1024 * 1024; // 10MB in bytes
const VALID_MIME_TYPES = ["image/jpeg", "image/png"] as const;

// Arbitrary for MIME types that are NOT jpeg or png
const invalidMimeArb = fc
  .string({ minLength: 1, maxLength: 50 })
  .filter((s) => s !== "image/jpeg" && s !== "image/png" && s.trim().length > 0);

// Arbitrary for file sizes > 10MB
const oversizedArb = fc.integer({ min: MAX_SIZE + 1, max: MAX_SIZE * 5 });

// Arbitrary for valid file sizes (0 to 10MB inclusive)
const validSizeArb = fc.integer({ min: 0, max: MAX_SIZE });

// Arbitrary for valid MIME types
const validMimeArb = fc.constantFrom(...VALID_MIME_TYPES);

describe("Property: Image upload validation", () => {
  it("rejects any file with an invalid MIME type regardless of size", () => {
    // Validates: Requirements 3.2, 3.3
    fc.assert(
      fc.property(invalidMimeArb, validSizeArb, (mimeType, sizeBytes) => {
        const result = validateImage(mimeType, sizeBytes);
        return result.valid === false;
      }),
      { numRuns: 100 }
    );
  });

  it("rejects any file exceeding 10MB regardless of MIME type", () => {
    // Validates: Requirements 3.3, 6.3
    fc.assert(
      fc.property(validMimeArb, oversizedArb, (mimeType, sizeBytes) => {
        const result = validateImage(mimeType, sizeBytes);
        return result.valid === false;
      }),
      { numRuns: 100 }
    );
  });

  it("rejects files with both invalid MIME type and size > 10MB", () => {
    // Validates: Requirements 3.2, 3.3
    fc.assert(
      fc.property(invalidMimeArb, oversizedArb, (mimeType, sizeBytes) => {
        const result = validateImage(mimeType, sizeBytes);
        return result.valid === false;
      }),
      { numRuns: 100 }
    );
  });

  it("accepts any valid JPEG or PNG file with size ≤ 10MB", () => {
    // Validates: Requirements 3.2, 6.3
    fc.assert(
      fc.property(validMimeArb, validSizeArb, (mimeType, sizeBytes) => {
        const result = validateImage(mimeType, sizeBytes);
        return result.valid === true;
      }),
      { numRuns: 100 }
    );
  });
});
