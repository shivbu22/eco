// Offline sync logic for Worker App
// Queues job status updates locally and replays them to the server on reconnect.

export interface QueuedUpdate {
  jobId: string;
  status: string;
  idempotencyKey: string;
  queuedAt: number; // epoch ms
}

export interface SyncResult {
  synced: number;
  failed: number;
}

// In-memory queue (in a real app this would be backed by AsyncStorage/SQLite)
let queue: QueuedUpdate[] = [];

// Track which idempotency keys have already been applied to the server
const appliedKeys = new Set<string>();

/**
 * Add a status update to the local queue.
 */
export function queueUpdate(jobId: string, status: string, idempotencyKey: string): void {
  queue.push({ jobId, status, idempotencyKey, queuedAt: Date.now() });
}

/**
 * Return the current queue of pending updates (in order).
 */
export function getQueue(): QueuedUpdate[] {
  return [...queue];
}

/**
 * Replay queued updates to the server in order.
 * Uses idempotency keys so the same update is never applied twice.
 * On success, removes the update from the queue.
 * Returns { synced, failed } counts.
 */
export async function syncQueue(
  serverApplyFn: (update: QueuedUpdate) => Promise<void>
): Promise<SyncResult> {
  let synced = 0;
  let failed = 0;

  // Snapshot the queue so we iterate a stable list
  const pending = [...queue];

  for (const update of pending) {
    // Idempotency: skip if already applied
    if (appliedKeys.has(update.idempotencyKey)) {
      // Remove from queue without counting as a new sync
      queue = queue.filter((u) => u.idempotencyKey !== update.idempotencyKey);
      continue;
    }

    try {
      await serverApplyFn(update);
      appliedKeys.add(update.idempotencyKey);
      queue = queue.filter((u) => u.idempotencyKey !== update.idempotencyKey);
      synced++;
    } catch {
      failed++;
    }
  }

  return { synced, failed };
}

/**
 * Clear the queue and applied-keys tracking. Intended for use in tests only.
 */
export function clearQueue(): void {
  queue = [];
  appliedKeys.clear();
}
