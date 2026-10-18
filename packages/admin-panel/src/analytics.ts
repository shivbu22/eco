// Admin Panel — Analytics and pricing logic
// Requirements: 12.1, 12.2, 12.3, 13.1, 13.4, 17.1, 17.4

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

export interface AnalyticsFilters {
  from?: string;
  to?: string;
  zone_id?: string;
  service_type?: string;
}

/** GET /analytics/summary — summary metrics with optional filters (Req 12.1, 12.2) */
export async function getAnalyticsSummary(
  filters: AnalyticsFilters,
  apiBase: string,
  token: string
): Promise<unknown> {
  const url = new URL(`${apiBase}/analytics/summary`);
  if (filters.from) url.searchParams.set("from", filters.from);
  if (filters.to) url.searchParams.set("to", filters.to);
  if (filters.zone_id) url.searchParams.set("zone_id", filters.zone_id);
  if (filters.service_type) url.searchParams.set("service_type", filters.service_type);
  const res = await fetch(url.toString(), { headers: authHeaders(token) });
  return handleResponse<unknown>(res);
}

/** GET /analytics/export — download CSV of filtered analytics data (Req 12.3) */
export async function exportAnalyticsCsv(
  filters: AnalyticsFilters,
  apiBase: string,
  token: string
): Promise<string> {
  const url = new URL(`${apiBase}/analytics/export`);
  if (filters.from) url.searchParams.set("from", filters.from);
  if (filters.to) url.searchParams.set("to", filters.to);
  if (filters.zone_id) url.searchParams.set("zone_id", filters.zone_id);
  if (filters.service_type) url.searchParams.set("service_type", filters.service_type);
  const res = await fetch(url.toString(), { headers: authHeaders(token) });
  if (!res.ok) {
    const body = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
    throw new Error(body?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.text();
}

/** GET /pricing — list all pricing rules (Req 13.4) */
export async function getPricing(apiBase: string, token: string): Promise<unknown[]> {
  const res = await fetch(`${apiBase}/pricing`, { headers: authHeaders(token) });
  return handleResponse<unknown[]>(res);
}

/** PATCH /pricing/:id — update a pricing rule (Req 13.1) */
export async function updatePricing(
  pricingId: string,
  updates: Record<string, unknown>,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/pricing/${pricingId}`, {
    method: "PATCH",
    headers: authHeaders(token),
    body: JSON.stringify(updates),
  });
  return handleResponse<unknown>(res);
}

/** GET /contracts — list all B2B contracts (Req 17.4) */
export async function getContracts(apiBase: string, token: string): Promise<unknown[]> {
  const res = await fetch(`${apiBase}/contracts`, { headers: authHeaders(token) });
  return handleResponse<unknown[]>(res);
}

/** POST /contracts — create a new B2B contract (Req 17.1) */
export async function createContract(
  input: Record<string, unknown>,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/contracts`, {
    method: "POST",
    headers: authHeaders(token),
    body: JSON.stringify(input),
  });
  return handleResponse<unknown>(res);
}
