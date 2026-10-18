import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import type { OTPRecord } from "@ecomins/shared";

// In-memory OTP store
const otpStore = new Map<string, OTPRecord>();

const OTP_EXPIRY_MS = 5 * 60 * 1000; // 5 minutes
const LOCKOUT_MS = 15 * 60 * 1000; // 15 minutes
const MAX_ATTEMPTS = 3;
const BCRYPT_ROUNDS = 10;
const JWT_SECRET = process.env.JWT_SECRET ?? "ecomins-dev-secret";
const JWT_EXPIRY = "24h";

// --- Core logic functions (exported for unit testing) ---

export function generateOtp(): string {
  const digits = Math.floor(100000 + Math.random() * 900000);
  return digits.toString();
}

export async function hashOtp(otp: string): Promise<string> {
  return bcrypt.hash(otp, BCRYPT_ROUNDS);
}

export async function compareOtp(otp: string, hash: string): Promise<boolean> {
  return bcrypt.compare(otp, hash);
}

export function isExpired(record: OTPRecord): boolean {
  return new Date() > new Date(record.expires_at);
}

export function isLocked(record: OTPRecord): boolean {
  if (!record.locked_until) return false;
  return new Date() < new Date(record.locked_until);
}

export function issueJwt(phone: string): string {
  return jwt.sign({ phone }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
}

/** Stub SMS dispatch — replace with real provider in production */
export function dispatchSms(phone: string, otp: string): void {
  console.log(`[SMS] Sending OTP ${otp} to ${phone}`);
}

// --- Request OTP ---

export async function requestOtp(phone: string): Promise<void> {
  const otp = generateOtp();
  const otp_hash = await hashOtp(otp);
  const expires_at = new Date(Date.now() + OTP_EXPIRY_MS).toISOString();

  const record: OTPRecord = {
    phone,
    otp_hash,
    expires_at,
    attempts: 0,
    locked_until: null,
  };

  otpStore.set(phone, record);
  dispatchSms(phone, otp);
}

// --- Verify OTP result types ---

export type VerifyResult =
  | { success: true; token: string }
  | { success: false; status: 401 | 429; code: string; message: string };

export async function verifyOtp(phone: string, otp: string): Promise<VerifyResult> {
  const record = otpStore.get(phone);

  if (!record) {
    return { success: false, status: 401, code: "INVALID_OTP", message: "Invalid OTP" };
  }

  // Check lockout first
  if (isLocked(record)) {
    const retryAfter = new Date(record.locked_until!).toISOString();
    return {
      success: false,
      status: 429,
      code: "ACCOUNT_LOCKED",
      message: `Too many attempts, retry after ${retryAfter}`,
    };
  }

  // Check expiry
  if (isExpired(record)) {
    otpStore.delete(phone);
    return { success: false, status: 401, code: "OTP_EXPIRED", message: "OTP expired" };
  }

  // Validate OTP
  const valid = await compareOtp(otp, record.otp_hash);

  if (!valid) {
    record.attempts += 1;

    if (record.attempts >= MAX_ATTEMPTS) {
      record.locked_until = new Date(Date.now() + LOCKOUT_MS).toISOString();
    }

    otpStore.set(phone, record);
    return { success: false, status: 401, code: "INVALID_OTP", message: "Invalid OTP" };
  }

  // Success — clean up and issue token
  otpStore.delete(phone);
  const token = issueJwt(phone);
  return { success: true, token };
}

// Expose store manipulation for testing only
export function _setOtpRecord(phone: string, record: OTPRecord): void {
  otpStore.set(phone, record);
}

export function _getOtpRecord(phone: string): OTPRecord | undefined {
  return otpStore.get(phone);
}

export function _clearOtpStore(): void {
  otpStore.clear();
}
