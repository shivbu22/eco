import { RewardsAccount } from "@ecomins/shared";

// In-memory store: customer_id → RewardsAccount
const store = new Map<string, RewardsAccount>();

/** Reset store (for testing) */
export function _clearStore(): void {
  store.clear();
}

/**
 * Get or create a RewardsAccount for a customer.
 * New accounts start with 0 balance and 0 eco_score.
 */
export function getAccount(customerId: string): RewardsAccount {
  if (!store.has(customerId)) {
    store.set(customerId, {
      customer_id: customerId,
      points_balance: 0,
      eco_score: 0,
    });
  }
  return store.get(customerId)!;
}

/**
 * Award Eco Points to a customer for a completed eco-service job.
 * - Adds points to points_balance
 * - eco_score = total points ever awarded (cumulative, never decremented)
 * Returns the updated RewardsAccount.
 */
export function awardPoints(
  customerId: string,
  points: number,
  _jobId: string
): RewardsAccount {
  const account = getAccount(customerId);
  account.points_balance += points;
  account.eco_score += points;
  return { ...account };
}

/**
 * Redeem Eco Points from a customer's balance.
 * - Validates balance >= requested points
 * - Deducts points from balance
 * - Returns updated RewardsAccount on success
 * - Throws an error if balance is insufficient (balance remains unchanged)
 */
export function redeemPoints(
  customerId: string,
  points: number
): RewardsAccount {
  const account = getAccount(customerId);

  if (account.points_balance < points) {
    throw new Error(
      `Insufficient balance: available ${account.points_balance}, requested ${points}`
    );
  }

  account.points_balance -= points;
  return { ...account };
}
