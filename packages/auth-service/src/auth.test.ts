import { describe, it, expect, beforeEach } from "vitest";
import {
  generateOtp,
  hashOtp,
  compareOtp,
  requestOtp,
  verifyOtp,
  _setOtpRecord,
  _clearOtpStore,
} from "./auth";
import type { OTPRecord } from "@ecomins/shared";

beforeEach(() => {
  _clearOtpStore();
});

// --- OTP generation ---

describe("generateOtp", () => {
  it("produces a 6-digit string", () => {
    for (let i = 0; i < 20; i++) {
      const otp = generateOtp();
      expect(otp).toMatch(/^\d{6}$/);
    }
  });

  it("produces values between 100000 and 999999", () => {
    for (let i = 0; i < 20; i++) {
      const n = parseInt(generateOtp(), 10);
      expect(n).toBeGreaterThanOrEqual(100000);
      expect(n).toBeLessThanOrEqual(999999);
    }
  });
});

// --- Hashing ---

describe("hashOtp / compareOtp", () => {
  it("hashed OTP matches original", async () => {
    const otp = "123456";
    const hash = await hashOtp(otp);
    expect(await compareOtp(otp, hash)).toBe(true);
  });

  it("wrong OTP does not match hash", async () => {
    const hash = await hashOtp("123456");
    expect(await compareOtp("654321", hash)).toBe(false);
  });
});

// --- Correct OTP within expiry returns a token ---

describe("verifyOtp — success", () => {
  it("returns a JWT token when OTP is correct and not expired", async () => {
    const phone = "+2348000000001";
    await requestOtp(phone);

    // Retrieve the stored record to get the hash, then verify with a known OTP
    // We need to inject a known OTP — use _setOtpRecord with a known hash
    const otp = "111111";
    const hash = await hashOtp(otp);
    const record: OTPRecord = {
      phone,
      otp_hash: hash,
      expires_at: new Date(Date.now() + 4 * 60 * 1000).toISOString(),
      attempts: 0,
      locked_until: null,
    };
    _setOtpRecord(phone, record);

    const result = await verifyOtp(phone, otp);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(typeof result.token).toBe("string");
      expect(result.token.length).toBeGreaterThan(0);
    }
  });
});

// --- Incorrect OTP increments attempts ---

describe("verifyOtp — incorrect OTP", () => {
  it("increments attempts on wrong OTP", async () => {
    const phone = "+2348000000002";
    const hash = await hashOtp("999999");
    const record: OTPRecord = {
      phone,
      otp_hash: hash,
      expires_at: new Date(Date.now() + 4 * 60 * 1000).toISOString(),
      attempts: 0,
      locked_until: null,
    };
    _setOtpRecord(phone, record);

    const result = await verifyOtp(phone, "000000");
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(401);
      expect(result.code).toBe("INVALID_OTP");
    }

    // Verify attempts incremented in store
    const { _getOtpRecord } = await import("./auth");
    const updated = _getOtpRecord(phone);
    expect(updated?.attempts).toBe(1);
  });
});

// --- After 3 failures, account is locked ---

describe("verifyOtp — lockout after 3 failures", () => {
  it("locks the account after 3 consecutive wrong OTPs", async () => {
    const phone = "+2348000000003";
    const hash = await hashOtp("777777");
    const record: OTPRecord = {
      phone,
      otp_hash: hash,
      expires_at: new Date(Date.now() + 4 * 60 * 1000).toISOString(),
      attempts: 0,
      locked_until: null,
    };
    _setOtpRecord(phone, record);

    // 3 wrong attempts
    await verifyOtp(phone, "000001");
    await verifyOtp(phone, "000002");
    await verifyOtp(phone, "000003");

    // 4th attempt should be locked
    const result = await verifyOtp(phone, "000004");
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(429);
      expect(result.code).toBe("ACCOUNT_LOCKED");
    }
  });

  it("rejects even the correct OTP when locked", async () => {
    const phone = "+2348000000004";
    const otp = "555555";
    const hash = await hashOtp(otp);
    const record: OTPRecord = {
      phone,
      otp_hash: hash,
      expires_at: new Date(Date.now() + 4 * 60 * 1000).toISOString(),
      attempts: 3,
      locked_until: new Date(Date.now() + 15 * 60 * 1000).toISOString(),
    };
    _setOtpRecord(phone, record);

    const result = await verifyOtp(phone, otp);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(429);
    }
  });
});

// --- Expired OTP returns 401 ---

describe("verifyOtp — expired OTP", () => {
  it("returns 401 with OTP_EXPIRED when OTP is past expiry", async () => {
    const phone = "+2348000000005";
    const otp = "333333";
    const hash = await hashOtp(otp);
    const record: OTPRecord = {
      phone,
      otp_hash: hash,
      expires_at: new Date(Date.now() - 1000).toISOString(), // 1 second in the past
      attempts: 0,
      locked_until: null,
    };
    _setOtpRecord(phone, record);

    const result = await verifyOtp(phone, otp);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(401);
      expect(result.code).toBe("OTP_EXPIRED");
    }
  });
});

// --- No record for phone ---

describe("verifyOtp — unknown phone", () => {
  it("returns 401 when no OTP record exists for phone", async () => {
    const result = await verifyOtp("+2340000000000", "123456");
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(401);
    }
  });
});
