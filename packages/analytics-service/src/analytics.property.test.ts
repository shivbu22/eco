// Feature: ecomins-platform, Property 14: Analytics filter correctness

import { describe, it, beforeEach } from "vitest";
import * as fc from "fast-check";
import { addJobRecord, getSummary, exportCsv, _clearStore } from "./analytics";
import type { Job } from "@ecomins/shared";

/**
 * Validates: Requirements 12.2
 *
 * For any analytics query with a date range filter, all returned Job records
 * should have `created_at` values within the specified range, and no Jobs
 * outside the range should appear.
 */

beforeEach(() => {
  _clearStore();
});

// Arbitrary that generates a valid ISO 8601 timestamp within a fixed epoch window
// (year 2020–2025) to keep dates realistic and comparable
const timestampArb = fc
  .integer({ min: 1577836800000, max: 1767225600000 }) // 2020-01-01 to 2026-01-01
  .map((ms) => new Date(ms).toISOString());

// Arbitrary for a single completed Job with a random created_at
const jobArb = (id: string): fc.Arbitrary<Job> =>
  fc.record({
    id: fc.constant(id),
    customer_id: fc.constant("cust-1"),
    worker_id: fc.constant("worker-1"),
    service_type: fc.constantFrom("cleaning", "recycling", "waste"),
    status: fc.constant("completed" as const),
    location: fc.constant({ lat: 0, lng: 0, address: "Test St" }),
    zone_id: fc.constantFrom("zone-a", "zone-b"),
    scheduled_time: fc.constant(null),
    before_photo_url: fc.constant(null),
    after_photo_url: fc.constant(null),
    price: fc.integer({ min: 10, max: 1000 }),
    created_at: timestampArb,
    updated_at: fc.constant("2024-01-01T00:00:00Z"),
  });

describe("Property 14: Analytics filter correctness", () => {
  it("getSummary: all counted jobs have created_at within the date range filter", () => {
    fc.assert(
      fc.property(
        // Generate a set of up to 20 jobs with random timestamps
        fc.array(fc.nat({ max: 19 }), { minLength: 1, maxLength: 20 }).chain((indices) =>
          fc.tuple(...indices.map((_, i) => jobArb(`job-${i}`)))
        ),
        // Generate a date range [from, to] where from <= to
        fc.tuple(timestampArb, timestampArb).map(([a, b]) =>
          new Date(a) <= new Date(b) ? { from: a, to: b } : { from: b, to: a }
        ),
        (jobs, { from, to }) => {
          _clearStore();

          for (const job of jobs) {
            addJobRecord(job);
          }

          const summary = getSummary({ from, to });

          // Count manually how many jobs fall within the range
          const fromMs = new Date(from).getTime();
          const toMs = new Date(to).getTime();
          const expected = jobs.filter((j) => {
            const t = new Date(j.created_at).getTime();
            return t >= fromMs && t <= toMs;
          }).length;

          return summary.total_jobs_completed === expected;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("getSummary: no out-of-range jobs appear in the count", () => {
    fc.assert(
      fc.property(
        fc.array(fc.nat({ max: 19 }), { minLength: 1, maxLength: 20 }).chain((indices) =>
          fc.tuple(...indices.map((_, i) => jobArb(`job-${i}`)))
        ),
        fc.tuple(timestampArb, timestampArb).map(([a, b]) =>
          new Date(a) <= new Date(b) ? { from: a, to: b } : { from: b, to: a }
        ),
        (jobs, { from, to }) => {
          _clearStore();

          for (const job of jobs) {
            addJobRecord(job);
          }

          const summary = getSummary({ from, to });

          const fromMs = new Date(from).getTime();
          const toMs = new Date(to).getTime();

          // Count jobs that are strictly outside the range
          const outOfRange = jobs.filter((j) => {
            const t = new Date(j.created_at).getTime();
            return t < fromMs || t > toMs;
          }).length;

          const inRange = jobs.length - outOfRange;

          // The summary count must not exceed the number of in-range jobs
          return summary.total_jobs_completed <= inRange;
        }
      ),
      { numRuns: 100 }
    );
  });

  it("exportCsv: all data rows have created_at within the date range filter", () => {
    fc.assert(
      fc.property(
        fc.array(fc.nat({ max: 19 }), { minLength: 1, maxLength: 20 }).chain((indices) =>
          fc.tuple(...indices.map((_, i) => jobArb(`job-${i}`)))
        ),
        fc.tuple(timestampArb, timestampArb).map(([a, b]) =>
          new Date(a) <= new Date(b) ? { from: a, to: b } : { from: b, to: a }
        ),
        (jobs, { from, to }) => {
          _clearStore();

          for (const job of jobs) {
            addJobRecord(job);
          }

          const csv = exportCsv({ from, to });
          const lines = csv.split("\n");

          // First line is the header; skip it
          const dataRows = lines.slice(1).filter((l) => l.trim() !== "");

          const fromMs = new Date(from).getTime();
          const toMs = new Date(to).getTime();

          // The created_at column is index 7 (0-based) in the CSV header:
          // id,customer_id,worker_id,service_type,status,zone_id,price,created_at,updated_at
          const CREATED_AT_COL = 7;

          for (const row of dataRows) {
            const cols = row.split(",");
            const createdAt = cols[CREATED_AT_COL];
            const t = new Date(createdAt).getTime();
            if (t < fromMs || t > toMs) {
              return false;
            }
          }

          return true;
        }
      ),
      { numRuns: 100 }
    );
  });
});
