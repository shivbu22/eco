// Feature: ecomins-platform, Property: Status change notification invariant

import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import * as fc from "fast-check";
import { sendNotification, getNotificationLog, _clearLog } from "./notification";

/**
 * Validates: Requirements 5.3, 14.1, 14.2, 14.3, 14.4
 *
 * For any valid job status transition, a notification event must be emitted
 * to the relevant parties (Customer and/or Worker).
 *
 * Status → notification mapping:
 *   pending   → "Job Confirmed"   to customer
 *   assigned  → "Worker Assigned" to customer + "New Job" to worker
 *   en_route  → "Worker Arriving" to customer
 *   completed → "Job Completed"   to customer
 */

// ---------------------------------------------------------------------------
// JobNotifier — maps job status transitions to notification calls
// ---------------------------------------------------------------------------

type JobStatus = "pending" | "assigned" | "en_route" | "completed";

interface NotifyCall {
  userId: string;
  title: string;
  body: string;
}

/**
 * Given a job status, dispatch the appropriate push notifications.
 * Returns the list of notification calls that were made.
 */
async function JobNotifier(
  status: JobStatus,
  customerId: string,
  workerId: string | null,
  dispatcher: (
    userId: string,
    title: string,
    body: string,
    data?: Record<string, unknown>
  ) => Promise<void>
): Promise<NotifyCall[]> {
  const calls: NotifyCall[] = [];

  switch (status) {
    case "pending":
      await sendNotification(customerId, "Job Confirmed", "Your job has been confirmed.", undefined, dispatcher);
      calls.push({ userId: customerId, title: "Job Confirmed", body: "Your job has been confirmed." });
      break;

    case "assigned":
      await sendNotification(customerId, "Worker Assigned", "A worker has been assigned to your job.", undefined, dispatcher);
      calls.push({ userId: customerId, title: "Worker Assigned", body: "A worker has been assigned to your job." });
      if (workerId) {
        await sendNotification(workerId, "New Job", "You have been assigned a new job.", undefined, dispatcher);
        calls.push({ userId: workerId, title: "New Job", body: "You have been assigned a new job." });
      }
      break;

    case "en_route":
      await sendNotification(customerId, "Worker Arriving", "Your worker is on the way.", undefined, dispatcher);
      calls.push({ userId: customerId, title: "Worker Arriving", body: "Your worker is on the way." });
      break;

    case "completed":
      await sendNotification(customerId, "Job Completed", "Your job has been completed.", undefined, dispatcher);
      calls.push({ userId: customerId, title: "Job Completed", body: "Your job has been completed." });
      break;
  }

  return calls;
}

// ---------------------------------------------------------------------------
// Arbitraries
// ---------------------------------------------------------------------------

const userId = () => fc.uuid();

const jobStatus = () =>
  fc.constantFrom<JobStatus>("pending", "assigned", "en_route", "completed");

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe("Property: Status change notification invariant", () => {
  beforeEach(() => {
    _clearLog();
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("every job status change triggers at least one notification to the customer", async () => {
    await fc.assert(
      fc.asyncProperty(
        jobStatus(),
        userId(),
        userId(),
        async (status, customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier(status, customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          // At least one notification must be sent
          expect(calls.length).toBeGreaterThanOrEqual(1);

          // The customer must always receive a notification
          const customerCalls = calls.filter((c) => c.userId === customerId);
          expect(customerCalls.length).toBeGreaterThanOrEqual(1);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("pending status triggers exactly 'Job Confirmed' to customer only", async () => {
    await fc.assert(
      fc.asyncProperty(
        userId(),
        userId(),
        async (customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier("pending", customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          expect(calls).toHaveLength(1);
          expect(calls[0].userId).toBe(customerId);
          expect(calls[0].title).toBe("Job Confirmed");

          // Verify the log captured the notification
          const log = getNotificationLog();
          const customerEntry = log.find((e) => e.userId === customerId && e.title === "Job Confirmed");
          expect(customerEntry).toBeDefined();
          expect(customerEntry!.success).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("assigned status triggers 'Worker Assigned' to customer and 'New Job' to worker", async () => {
    await fc.assert(
      fc.asyncProperty(
        userId(),
        userId(),
        async (customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier("assigned", customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          expect(calls).toHaveLength(2);

          const customerCall = calls.find((c) => c.userId === customerId);
          expect(customerCall).toBeDefined();
          expect(customerCall!.title).toBe("Worker Assigned");

          const workerCall = calls.find((c) => c.userId === workerId);
          expect(workerCall).toBeDefined();
          expect(workerCall!.title).toBe("New Job");

          // Both must appear in the log
          const log = getNotificationLog();
          expect(log.some((e) => e.userId === customerId && e.title === "Worker Assigned" && e.success)).toBe(true);
          expect(log.some((e) => e.userId === workerId && e.title === "New Job" && e.success)).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("en_route status triggers exactly 'Worker Arriving' to customer only", async () => {
    await fc.assert(
      fc.asyncProperty(
        userId(),
        userId(),
        async (customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier("en_route", customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          expect(calls).toHaveLength(1);
          expect(calls[0].userId).toBe(customerId);
          expect(calls[0].title).toBe("Worker Arriving");

          const log = getNotificationLog();
          const entry = log.find((e) => e.userId === customerId && e.title === "Worker Arriving");
          expect(entry).toBeDefined();
          expect(entry!.success).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("completed status triggers exactly 'Job Completed' to customer only", async () => {
    await fc.assert(
      fc.asyncProperty(
        userId(),
        userId(),
        async (customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier("completed", customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          expect(calls).toHaveLength(1);
          expect(calls[0].userId).toBe(customerId);
          expect(calls[0].title).toBe("Job Completed");

          const log = getNotificationLog();
          const entry = log.find((e) => e.userId === customerId && e.title === "Job Completed");
          expect(entry).toBeDefined();
          expect(entry!.success).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("all notifications are logged as successful when dispatcher succeeds", async () => {
    await fc.assert(
      fc.asyncProperty(
        jobStatus(),
        userId(),
        userId(),
        async (status, customerId, workerId) => {
          _clearLog();
          const dispatcher = vi.fn().mockResolvedValue(undefined);

          const resultPromise = JobNotifier(status, customerId, workerId, dispatcher);
          await vi.runAllTimersAsync();
          const calls = await resultPromise;

          const log = getNotificationLog();
          // Every call made must have a corresponding successful log entry
          for (const call of calls) {
            const entry = log.find(
              (e) => e.userId === call.userId && e.title === call.title && e.success
            );
            expect(entry).toBeDefined();
          }
        }
      ),
      { numRuns: 100 }
    );
  });
});
