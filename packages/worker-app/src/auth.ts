// Worker App — Auth + KYC logic
// Requirements: 7.1, 7.2

let _token: string | null = null;

/** Return the in-memory auth token, or null if not authenticated. */
export function getToken(): string | null {
  return _token;
}

/** Clear the in-memory auth token (logout). */
export function clearToken(): void {
  _token = null;
}

/**
 * Request an OTP for the given phone number.
 * POST ${apiBase}/auth/request-otp
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
 * Verify an OTP and store the returned token in memory.
 * POST ${apiBase}/auth/verify-otp
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
  const { token } = await res.json();
  _token = token;
  return token;
}

/**
 * Submit KYC documents for a worker.
 * POST ${apiBase}/workers/${workerId}/kyc
 */
export async function submitKyc(
  workerId: string,
  idDocumentUrl: string,
  selfieUrl: string,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/workers/${workerId}/kyc`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ id_document_url: idDocumentUrl, selfie_url: selfieUrl }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Submit KYC failed: ${res.status}`);
  }
}
