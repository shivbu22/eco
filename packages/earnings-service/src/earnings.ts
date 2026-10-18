import { EarningsRecord } from "@ecomins/shared";
import { randomUUID } from "crypto";

// In-memory store: worker_id → EarningsRecord[]
const store = new Map<string, EarningsRecord[]>();

/** Reset store (for testing) */
export function _resetStore(): void {
  store.clear();
}

/**
 * Calculate net earnings for a completed job and persist the record.
 * net_amount = grossAmount * (1 - commissionRate)
 */
export function calculateEarnings(
  workerId: string,
  jobId: string,
  grossAmount: number,
  commissionRate: number
): EarningsRecord {
  const net_amount = grossAmount * (1 - commissionRate);

  const record: EarningsRecord = {
    id: randomUUID(),
    worker_id: workerId,
    job_id: jobId,
    gross_amount: grossAmount,
    commission_rate: commissionRate,
    net_amount,
    created_at: new Date().toISOString(),
  };

  const existing = store.get(workerId) ?? [];
  existing.push(record);
  store.set(workerId, existing);

  return record;
}

export interface EarningsSummary {
  today: number;
  week: number;
  all_time: number;
}

/**
 * Aggregate today / current-week / all-time net earnings for a worker.
 */
export function getEarningsSummary(workerId: string): EarningsSummary {
  const records = store.get(workerId) ?? [];

  const now = new Date();
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  // Monday of the current week
  const dayOfWeek = now.getDay(); // 0 = Sunday
  const daysFromMonday = (dayOfWeek + 6) % 7;
  const startOfWeek = new Date(startOfToday);
  startOfWeek.setDate(startOfToday.getDate() - daysFromMonday);

  let today = 0;
  let week = 0;
  let all_time = 0;

  for (const r of records) {
    const created = new Date(r.created_at);
    all_time += r.net_amount;
    if (created >= startOfWeek) week += r.net_amount;
    if (created >= startOfToday) today += r.net_amount;
  }

  return { today, week, all_time };
}

/**
 * Return all EarningsRecords for a given worker.
 */
export function getEarningsByWorker(workerId: string): EarningsRecord[] {
  return store.get(workerId) ?? [];
}
