import { RecyclingRecord } from "@ecomins/shared";
import { randomUUID } from "crypto";

// Buy rates per kg in currency units (Requirements 18.3, 18.4)
export const BUY_RATES: Record<RecyclingRecord["waste_category"], number> = {
  scrap_metal: 15,
  paper: 5,
  plastic: 8,
  e_waste: 25,
};

// In-memory store: job_id → RecyclingRecord
const store = new Map<string, RecyclingRecord>();

/** Reset store (for testing) */
export function _clearStore(): void {
  store.clear();
}

/**
 * Record a recycling job and calculate payout.
 * payout_amount = weight_kg * BUY_RATES[waste_category]
 * Requirements: 18.3, 18.4, 18.5
 */
export function recordRecycling(
  jobId: string,
  customerId: string,
  wasteCategory: RecyclingRecord["waste_category"],
  weightKg: number,
  payoutPreference: RecyclingRecord["payout_preference"]
): RecyclingRecord {
  const payout_amount = weightKg * BUY_RATES[wasteCategory];

  const record: RecyclingRecord = {
    id: randomUUID(),
    job_id: jobId,
    customer_id: customerId,
    waste_category: wasteCategory,
    weight_kg: weightKg,
    payout_amount,
    payout_preference: payoutPreference,
    payout_status: "pending",
    created_at: new Date().toISOString(),
  };

  store.set(jobId, record);
  return record;
}

/**
 * Retrieve a recycling record by job ID.
 * Returns null if not found.
 */
export function getRecyclingRecord(jobId: string): RecyclingRecord | null {
  return store.get(jobId) ?? null;
}
