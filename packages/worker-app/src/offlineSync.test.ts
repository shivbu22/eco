import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  queueUpdate,
  getQueue,
  syncQueue,
  clearQueue,
  QueuedUpdate,
} from "./offlineSync";

beforeEach(() => {
  clearQueue();
});

describe("queueUpdate", () => {
  it("adds an update to the queue", () => {
    queueUpdate("job-1", "in_progress", "key-1");
    const q = getQueue();
    expect(q).toHaveLength(1);
    expect(q[0]).toMatchObject({ jobId: "job-1", status: "in_progress", idempotencyKey: "key-1" });
  });

  it("adds multiple updates in order", () => {
    queueUpdate("job-1", "in_progress", "key-1");
    queueUpdate("job-1", "completed", "key-2");
    const q = getQueue();
    expect(q).toHaveLength(2);
    expect(q[0].idempotencyKey).toBe("key-1");
    expect(q[1].idempotencyKey).toBe("key-2");
  });
});

describe("syncQueue", () => {
  it("calls serverApplyFn for each queued update in order", async () => {
    queueUpdate("job-1", "in_progress", "key-1");
    queueUpdate("job-1", "completed", "key-2");

    const calls: QueuedUpdate[] = [];
    await syncQueue(async (u) => { calls.push(u); });

    expect(calls).toHaveLength(2);
    expect(calls[0].idempotencyKey).toBe("key-1");
    expect(calls[1].idempotencyKey).toBe("key-2");
  });

  it("removes successfully synced updates from the queue", async () => {
    queueUpdate("job-1", "in_progress", "key-1");
    queueUpdate("job-1", "completed", "key-2");

    await syncQueue(async () => {});

    expect(getQueue()).toHaveLength(0);
  });

  it("returns correct synced count on full success", async () => {
    queueUpdate("job-1", "in_progress", "key-1");
    queueUpdate("job-2", "completed", "key-2");

    const result = await syncQueue(async () => {});
    expect(result.synced).toBe(2);
    expect(result.failed).toBe(0);
  });

  it("handles server failures gracefully — keeps failed updates in queue", async () => {
    queueUpdate("job-1", "in_progress", "key-1");
    queueUpdate("job-2", "completed", "key-2");

    // First call fails, second succeeds
    const serverApplyFn = vi
      .fn()
      .mockRejectedValueOnce(new Error("network error"))
      .mockResolvedValueOnce(undefined);

    const result = await syncQueue(serverApplyFn);

    expect(result.synced).toBe(1);
    expect(result.failed).toBe(1);
    // Failed update stays in queue
    expect(getQueue()).toHaveLength(1);
    expect(getQueue()[0].idempotencyKey).toBe("key-1");
  });

  it("returns { synced: 0, failed: 0 } when queue is empty", async () => {
    const result = await syncQueue(async () => {});
    expect(result).toEqual({ synced: 0, failed: 0 });
  });

  describe("idempotency", () => {
    it("does not apply the same idempotencyKey twice across multiple syncQueue calls", async () => {
      queueUpdate("job-1", "in_progress", "key-1");

      const calls: string[] = [];
      const serverApplyFn = async (u: QueuedUpdate) => { calls.push(u.idempotencyKey); };

      // First sync — applies the update
      await syncQueue(serverApplyFn);
      expect(calls).toHaveLength(1);

      // Re-queue the same update (simulating a crash/re-queue scenario)
      queueUpdate("job-1", "in_progress", "key-1");

      // Second sync — should NOT apply again
      await syncQueue(serverApplyFn);
      expect(calls).toHaveLength(1);
    });

    it("calling syncQueue multiple times with the same queue produces the same result", async () => {
      queueUpdate("job-1", "in_progress", "key-1");
      queueUpdate("job-1", "completed", "key-2");

      const calls: string[] = [];
      const serverApplyFn = async (u: QueuedUpdate) => { calls.push(u.idempotencyKey); };

      const r1 = await syncQueue(serverApplyFn);
      expect(r1).toEqual({ synced: 2, failed: 0 });

      // Re-add same updates to queue
      queueUpdate("job-1", "in_progress", "key-1");
      queueUpdate("job-1", "completed", "key-2");

      const r2 = await syncQueue(serverApplyFn);
      // Already applied — nothing new applied, nothing failed
      expect(r2).toEqual({ synced: 0, failed: 0 });
      // Server was never called again
      expect(calls).toHaveLength(2);
    });
  });
});
