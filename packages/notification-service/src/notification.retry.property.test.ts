// Feature: ecomins-platform, Property: Notification retry behavior

import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import * as fc from "fast-check";
import { sendNotification, getNotificationLog, _clearLog } from "./notification";

/**
 * Validates: Requirements 14.5
 *
 * For any notification that fails delivery on all attempts, the service
 * retries exactly up to 3 times (4 total attempts) and logs a failure
 * after all retries are exhausted.
 */

describe("Property: Notification retry behavior", () => {
  beforeEach(() => {
    _clearLog();
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("always retries exactly 3 times (4 total attempts) when all deliveries fail", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 50 }),  // userId
        fc.string({ minLength: 1, maxLength: 100 }), // title
        fc.string({ minLength: 1, maxLength: 200 }), // body
        fc.string({ minLength: 1, maxLength: 100 }), // error message
        async (userId, title, body, errorMessage) => {
          _clearLog();

          const dispatcher = vi.fn().mockRejectedValue(new Error(errorMessage));

          const resultPromise = sendNotification(userId, title, body, undefined, dispatcher);
          await vi.runAllTimersAsync();
          const result = await resultPromise;

          // Must have made exactly 4 calls (1 initial + 3 retries)
          expect(dispatcher).toHaveBeenCalledTimes(4);

          // Result must indicate failure
          expect(result.success).toBe(false);
          expect(result.attempts).toBe(4);
          expect(result.failureReason).toBe(errorMessage);

          // Log must contain exactly 4 entries, all failures
          const log = getNotificationLog().filter((e) => e.userId === userId);
          expect(log).toHaveLength(4);
          expect(log.every((e) => e.success === false)).toBe(true);
          expect(log.map((e) => e.attempt)).toEqual([1, 2, 3, 4]);
          expect(log.every((e) => e.error === errorMessage)).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  it("stops retrying and logs failure once all 3 retries are exhausted", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 50 }),
        fc.string({ minLength: 1, maxLength: 100 }),
        fc.string({ minLength: 1, maxLength: 200 }),
        async (userId, title, body) => {
          _clearLog();

          const dispatcher = vi.fn().mockRejectedValue(new Error("delivery-failed"));

          const resultPromise = sendNotification(userId, title, body, undefined, dispatcher);
          await vi.runAllTimersAsync();
          const result = await resultPromise;

          // Never exceeds 4 total attempts (no infinite retry)
          expect(dispatcher.mock.calls.length).toBeLessThanOrEqual(4);
          expect(dispatcher.mock.calls.length).toBeGreaterThanOrEqual(4);

          // Final result is always a logged failure
          expect(result.success).toBe(false);
          expect(result.failureReason).toBeDefined();
        }
      ),
      { numRuns: 100 }
    );
  });
});
