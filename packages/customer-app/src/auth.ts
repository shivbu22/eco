// Customer App — Auth screen logic
// Requirements: 1.1, 1.2, 1.3, 1.4

/** In-memory token store (no AsyncStorage needed for this stub) */
const tokenStore: { token: string | null } = { token: null };

/**
 * Request an OTP for the given phone number.
 * POSTs to ${apiBase}/auth/request-otp
 */
export async function requestOtp(phone: string, apiBase: string): Promise<void> {
  const res = await fetch(`${apiBase}/auth/request-otp`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Request OTP failed: ${res.status}`);
  }
}

/**
 * Verify an OTP and store the returned JWT token.
 * POSTs to ${apiBase}/auth/verify-otp
 * Returns the session token on success.
 */
export async function verifyOtp(
  phone: string,
  otp: string,
  apiBase: string
): Promise<string> {
  const res = await fetch(`${apiBase}/auth/verify-otp`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, otp }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Verify OTP failed: ${res.status}`);
  }
  const data = await res.json();
  const token: string = data.token;
  tokenStore.token = token;
  return token;
}

/** Retrieve the currently stored session token (null if not authenticated). */
export function getToken(): string | null {
  return tokenStore.token;
}

/** Clear the stored session token (logout). */
export function clearToken(): void {
  tokenStore.token = null;
}
