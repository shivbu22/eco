// Admin Panel — Worker management logic
// Requirements: 11.1, 11.2, 11.3, 11.4, 11.5

async function handleResponse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
    throw new Error(body?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
}

const authHeaders = (token: string) => ({
  Authorization: `Bearer ${token}`,
  "Content-Type": "application/json",
});

/** GET /workers — list all workers with status, zone, skills, rating (Req 11.1) */
export async function getWorkers(apiBase: string, token: string): Promise<unknown[]> {
  const res = await fetch(`${apiBase}/workers`, { headers: authHeaders(token) });
  return handleResponse<unknown[]>(res);
}

/** PATCH /workers/:id/kyc/review — approve or reject KYC submission (Req 11.3) */
export async function reviewKyc(
  workerId: string,
  approved: boolean,
  reason: string | undefined,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/workers/${workerId}/kyc/review`, {
    method: "PATCH",
    headers: authHeaders(token),
    body: JSON.stringify({ approved, reason }),
  });
  return handleResponse<unknown>(res);
}

/** PATCH /workers/:id/zone — assign or reassign worker zone (Req 11.4) */
export async function assignZone(
  workerId: string,
  zoneId: string,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/workers/${workerId}/zone`, {
    method: "PATCH",
    headers: authHeaders(token),
    body: JSON.stringify({ zone_id: zoneId }),
  });
  return handleResponse<unknown>(res);
}

/** GET /workers/:id — get full worker profile (Req 11.5) */
export async function getWorkerProfile(
  workerId: string,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/workers/${workerId}`, { headers: authHeaders(token) });
  return handleResponse<unknown>(res);
}
