// Feature: ecomins-platform, Property 13: Offline sync idempotency

import { describe, it, expect, beforeEach } from "vitest";
import * as fc from "fast-check";
import { queueUpdate, syncQueue, clearQueue, QueuedUpdate } from "./offlineSync";

beforeEach(() => {
  clearQueue();
});

/**
 * Property 13: Offline sync idempotency
 * Validates: Requirements 16.2, 16.3
 *
 * For any set of locally buffered status updates, syncing them once and syncing
 * them multiple times produces the same final server state:
 *   - same set of applied idempotency keys
 *   - same number of server calls (no duplicate calls after first sync)
 */
describe("Property 13: Offline sync idempotency", () => {
  it(
    "syncing once and syncing multiple times produces the same applied idempotency keys",
    async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate 1–10 updates with unique idempotency keys
          fc.array(
            fc.record({
              jobId: fc.uuid(),
              status: fc.constantFrom(
                "in_progress",
                "completed",
                "en_route",
                "assigned"
              ),
              idempotencyKey: fc.uuid(),
            }),
            { minLength: 1, maxLength: 10 }
          ),
          // Number of extra sync passes (1–4 additional syncs after the first)
          fc.integer({ min: 1, max: 4 }),
          async (updates, extraSyncs) => {
            // Deduplicate idempotency keys so the input is realistic
            const seen = new Set<string>();
            const uniqueUpdates = updates.filter((u) => {
              if (seen.has(u.idempotencyKey)) return false;
              seen.add(u.idempotencyKey);
              return true;
            });

            clearQueue();

            // --- First sync ---
            for (const u of uniqueUpdates) {
              queueUpdate(u.jobId, u.status, u.idempotencyKey);
            }

            const appliedOnFirstSync: string[] = [];
            await syncQueue(async (update: QueuedUpdate) => {
              appliedOnFirstSync.push(update.idempotencyKey);
            });

            const firstSyncKeys = new Set(appliedOnFirstSync);

            // --- Subsequent syncs (re-queue the same updates each time) ---
            const appliedOnSubsequentSyncs: string[] = [];
            for (let i = 0; i < extraSyncs; i++) {
              // Re-queue the same updates (simulating a crash/re-queue scenario)
              for (const u of uniqueUpdates) {
                queueUpdate(u.jobId, u.status, u.idempotencyKey);
              }
              await syncQueue(async (update: QueuedUpdate) => {
                appliedOnSubsequentSyncs.push(update.idempotencyKey);
              });
            }

            // The server should never have been called again for already-applied keys
            expect(appliedOnSubsequentSyncs).toHaveLength(0);

            // The set of applied keys from the first sync must equal the full set of unique keys
            expect(firstSyncKeys.size).toBe(uniqueUpdates.length);
            for (const u of uniqueUpdates) {
              expect(firstSyncKeys.has(u.idempotencyKey)).toBe(true);
            }
          }
        ),
        { numRuns: 100 }
      );
    }
  );

  it(
    "total server calls across all syncs equals the number of unique updates (no duplicates)",
    async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.array(
            fc.record({
              jobId: fc.uuid(),
              status: fc.constantFrom("in_progress", "completed", "en_route"),
              idempotencyKey: fc.uuid(),
            }),
            { minLength: 1, maxLength: 10 }
          ),
          fc.integer({ min: 2, max: 5 }),
          async (updates, totalSyncs) => {
            const seen = new Set<string>();
            const uniqueUpdates = updates.filter((u) => {
              if (seen.has(u.idempotencyKey)) return false;
              seen.add(u.idempotencyKey);
              return true;
            });

            clearQueue();

            let totalServerCalls = 0;

            for (let syncPass = 0; syncPass < totalSyncs; syncPass++) {
              // Re-queue all updates on every pass (worst-case duplicate scenario)
              for (const u of uniqueUpdates) {
                queueUpdate(u.jobId, u.status, u.idempotencyKey);
              }
              await syncQueue(async () => {
                totalServerCalls++;
              });
            }

            // Regardless of how many sync passes, the server is called exactly once per unique key
            expect(totalServerCalls).toBe(uniqueUpdates.length);
          }
        ),
        { numRuns: 100 }
      );
    }
  );
});
