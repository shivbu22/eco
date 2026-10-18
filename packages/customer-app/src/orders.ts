// Customer App — Orders and Rewards logic
// Requirements: 15.3, 9.3

export interface Job {
  id: string;
  service_type: string;
  status: string;
  price: number;
  created_at: string;
  before_photo_url: string | null;
  after_photo_url: string | null;
}

export interface RewardsAccount {
  points: number;
  eco_score: number;
}

/**
 * Fetch all orders (jobs) for a customer.
 * Requirement 9.3 (customer side): list active and past jobs.
 * GET ${apiBase}/jobs?customer_id=${customerId}
 */
export async function getOrders(
  customerId: string,
  apiBase: string,
  token: string
): Promise<Job[]> {
  const res = await fetch(`${apiBase}/jobs?customer_id=${encodeURIComponent(customerId)}`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Get orders failed: ${res.status}`);
  }
  return res.json();
}

/**
 * Fetch rewards (Eco Points + Eco Score) for a customer.
 * Requirement 15.3: display Eco Points balance and Eco Score.
 * GET ${apiBase}/rewards/${customerId}
 */
export async function getRewards(
  customerId: string,
  apiBase: string,
  token: string
): Promise<RewardsAccount> {
  const res = await fetch(`${apiBase}/rewards/${encodeURIComponent(customerId)}`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Get rewards failed: ${res.status}`);
  }
  return res.json();
}
