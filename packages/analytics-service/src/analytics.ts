// Analytics Service — aggregation and CSV export
// Requirements: 12.1, 12.2, 12.3

import type { Job } from "@ecomins/shared";

export interface AnalyticsFilters {
  from?: string;       // ISO 8601 date string (inclusive)
  to?: string;         // ISO 8601 date string (inclusive)
  zone_id?: string;
  service_type?: string;
}

export interface AnalyticsSummary {
  total_jobs_completed: number;
  total_revenue: number;
  active_worker_count: number;
}

// In-memory store (simulates read replica)
let store: Job[] = [];

/** Add a Job record to the analytics store */
export function addJobRecord(job: Job): void {
  store.push(job);
}

/** Clear the store — for testing only */
export function _clearStore(): void {
  store = [];
}

/** Apply filters to the store, returning only matching completed jobs */
function filterJobs(filters: AnalyticsFilters): Job[] {
  return store.filter((job) => {
    if (job.status !== "completed") return false;

    if (filters.from) {
      if (new Date(job.created_at) < new Date(filters.from)) return false;
    }
    if (filters.to) {
      if (new Date(job.created_at) > new Date(filters.to)) return false;
    }
    if (filters.zone_id && job.zone_id !== filters.zone_id) return false;
    if (filters.service_type && job.service_type !== filters.service_type) return false;

    return true;
  });
}

/**
 * Aggregate total jobs completed, total revenue, and active worker count
 * for the given filters. Requirements: 12.1, 12.2
 */
export function getSummary(filters: AnalyticsFilters = {}): AnalyticsSummary {
  const jobs = filterJobs(filters);

  const total_jobs_completed = jobs.length;
  const total_revenue = jobs.reduce((sum, j) => sum + j.price, 0);
  const active_worker_count = new Set(
    jobs.filter((j) => j.worker_id !== null).map((j) => j.worker_id as string)
  ).size;

  return { total_jobs_completed, total_revenue, active_worker_count };
}

const CSV_HEADERS = [
  "id",
  "customer_id",
  "worker_id",
  "service_type",
  "status",
  "zone_id",
  "price",
  "created_at",
  "updated_at",
];

function escapeCsvField(value: unknown): string {
  const str = value === null || value === undefined ? "" : String(value);
  // Wrap in quotes if the value contains a comma, quote, or newline
  if (str.includes(",") || str.includes('"') || str.includes("\n")) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

/**
 * Return a CSV string of filtered Job records (header + data rows).
 * Requirements: 12.3
 */
export function exportCsv(filters: AnalyticsFilters = {}): string {
  const jobs = filterJobs(filters);

  const rows: string[] = [CSV_HEADERS.join(",")];

  for (const job of jobs) {
    const row = CSV_HEADERS.map((h) => escapeCsvField((job as Record<string, unknown>)[h]));
    rows.push(row.join(","));
  }

  return rows.join("\n");
}
