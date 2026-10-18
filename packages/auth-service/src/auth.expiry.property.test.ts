// Feature: ecomins-platform, Property 2: OTP expiry invalidation

import { describe, it, beforeEach, beforeAll } from "vitest";
import * as fc from "fast-check";
import { hashOtp, verifyOtp, _setOtpRecord, _clearOtpStore } from "./auth";
import type { OTPRecord } from "@ecomins/shared";

/**
 * Validates: Requirements 1.4
 *
 * Property 2: OTP expiry invalidation
 *
 * For any OTP that was issued more than 5 minutes ago (expires_at set to a
 * past timestamp), submitting it should result in status 401 with code
 * OTP_EXPIRED, regardless of whether the OTP value is correct or not.
 */

// E.164-like phone arbitrary: +[1-9][0-9]{6,14}
const phoneArbitrary = fc
  .tuple(
    fc.integer({ min: 1, max: 9 }),
    fc.stringOf(fc.constantFrom("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"), {
      minLength: 6,
      maxLength: 14,
    })
  )
  .map(([first, rest]) => `+${first}${rest}`);

// Past expiry: between 5 minutes + 1 second and 24 hours ago
const pastExpiryArbitrary = fc
  .integer({ min: 1, max: 24 * 60 * 60 * 1000 - 1 })
  .map((offsetMs) => new Date(Date.now() - (5 * 60 * 1000 + offsetMs)).toISOString());

// Pre-computed hash to avoid bcrypt overhead inside property loops
let correctOtpHash: string;
const CORRECT_OTP = "123456";

beforeAll(async () => {
  correctOtpHash = await hashOtp(CORRECT_OTP);
});

describe("Property 2: OTP expiry invalidation", () => {
  beforeEach(() => {
    _clearOtpStore();
  });

  /**
   * Core expiry property: submitting the CORRECT OTP value after expiry
   * must still return 401 OTP_EXPIRED.
   */
  it("rejects the correct OTP with 401 OTP_EXPIRED when expires_at is in the past", async () => {
    await fc.assert(
      fc.asyncProperty(phoneArbitrary, pastExpiryArbitrary, async (phone, expires_at) => {
        _clearOtpStore();

        const record: OTPRecord = {
          phone,
          otp_hash: correctOtpHash,
          expires_at,
          attempts: 0,
          locked_until: null,
        };
        _setOtpRecord(phone, record);

        const result = await verifyOtp(phone, CORRECT_OTP);

        if (result.success !== false) return false;
        if (result.status !== 401) return false;
        if (result.code !== "OTP_EXPIRED") return false;

        return true;
      }),
      { numRuns: 100 }
    );
  });

  /**
   * Generalised expiry property: any OTP value (correct or not) submitted
   * against an expired record must return 401 OTP_EXPIRED.
   */
  it("rejects any OTP value with 401 OTP_EXPIRED when the record is expired", async () => {
    await fc.assert(
      fc.asyncProperty(
        phoneArbitrary,
        pastExpiryArbitrary,
        fc.integer({ min: 100000, max: 999999 }).map((n) => n.toString()),
        async (phone, expires_at, submittedOtp) => {
          _clearOtpStore();

          const record: OTPRecord = {
            phone,
            otp_hash: correctOtpHash,
            expires_at,
            attempts: 0,
            locked_until: null,
          };
          _setOtpRecord(phone, record);

          const result = await verifyOtp(phone, submittedOtp);

          if (result.success !== false) return false;
          if (result.status !== 401) return false;
          if (result.code !== "OTP_EXPIRED") return false;

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });
});
