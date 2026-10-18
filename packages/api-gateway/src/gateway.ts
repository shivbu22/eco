import * as jwt from "jsonwebtoken";

// --- validateJwt ---

export interface JwtValidResult {
  valid: true;
  payload: { userId: string; role: string };
}

export interface JwtInvalidResult {
  valid: false;
  error: string;
}

export type JwtValidationResult = JwtValidResult | JwtInvalidResult;

/**
 * Verify a JWT token and extract userId and role from its payload.
 * Returns { valid: true, payload: { userId, role } } on success,
 * or { valid: false, error } on failure.
 */
export function validateJwt(token: string, secret: string): JwtValidationResult {
  try {
    const decoded = jwt.verify(token, secret) as jwt.JwtPayload;
    const userId = decoded["userId"] ?? decoded["sub"];
    const role = decoded["role"];

    if (!userId || !role) {
      return { valid: false, error: "Token payload missing userId or role" };
    }

    return { valid: true, payload: { userId: String(userId), role: String(role) } };
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Invalid token";
    return { valid: false, error: message };
  }
}

// --- createRateLimiter ---

interface RateLimiterWindow {
  count: number;
  windowStart: number;
}

/**
 * Create a rate limiter function.
 * Authenticated users (non-null userId): maxRequests per windowMs.
 * Unauthenticated (null userId): 10 req/min regardless of maxRequests.
 *
 * Returns true if the request is allowed, false if rate limited.
 */
export function createRateLimiter(
  maxRequests: number,
  windowMs: number
): (userId: string | null) => boolean {
  const windows = new Map<string, RateLimiterWindow>();

  return function rateLimiter(userId: string | null): boolean {
    const key = userId ?? "__unauthenticated__";
    const limit = userId !== null ? maxRequests : 10;
    const now = Date.now();

    const entry = windows.get(key);

    if (!entry || now - entry.windowStart >= windowMs) {
      // Start a new window
      windows.set(key, { count: 1, windowStart: now });
      return true;
    }

    if (entry.count < limit) {
      entry.count += 1;
      return true;
    }

    return false;
  };
}

// --- createErrorEnvelope ---

export interface ErrorEnvelope {
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

/**
 * Create a standard error envelope used across all API responses.
 */
export function createErrorEnvelope(
  code: string,
  message: string,
  details?: unknown
): ErrorEnvelope {
  const envelope: ErrorEnvelope = {
    error: { code, message },
  };
  if (details !== undefined) {
    envelope.error.details = details;
  }
  return envelope;
}
