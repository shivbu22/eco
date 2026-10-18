// Worker App — Availability + Earnings logic
// Requirements: 8.5, 8.6, 9.3, 9.4

function authHeaders(token: string): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  };
}

export interface EarningsSummary {
  today: number;
  week: number;
  all_time: number;
}

/**
 * Toggle worker availability.
 * PATCH ${apiBase}/workers/${workerId}/availability
 */
export async function toggleAvailability(
  workerId: string,
  available: boolean,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/workers/${workerId}/availability`, {
    method: "PATCH",
    headers: authHeaders(token),
    body: JSON.stringify({ available }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Toggle availability failed: ${res.status}`);
  }
}

/**
 * Fetch earnings summary for a worker.
 * GET ${apiBase}/earnings/${workerId}
 */
export async function getEarnings(
  workerId: string,
  apiBase: string,
  token: string
): Promise<EarningsSummary> {
  const res = await fetch(`${apiBase}/earnings/${workerId}`, {
    headers: authHeaders(token),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Get earnings failed: ${res.status}`);
  }
  return res.json();
}
