import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  sendNotification,
  getNotificationLog,
  _clearLog,
} from "./notification";

describe("Notification Service", () => {
  beforeEach(() => {
    _clearLog();
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("successful dispatch on first attempt returns success=true, attempts=1", async () => {
    const dispatcher = vi.fn().mockResolvedValue(undefined);

    const resultPromise = sendNotification("user-1", "Hello", "World", undefined, dispatcher);
    // No timers needed — succeeds immediately
    await vi.runAllTimersAsync();
    const result = await resultPromise;

    expect(result.success).toBe(true);
    expect(result.attempts).toBe(1);
    expect(result.failureReason).toBeUndefined();
    expect(dispatcher).toHaveBeenCalledTimes(1);
  });

  it("failed dispatch retries up to 3 times then returns success=false", async () => {
    const dispatcher = vi.fn().mockRejectedValue(new Error("FCM unavailable"));

    const resultPromise = sendNotification("user-2", "Title", "Body", undefined, dispatcher);
    await vi.runAllTimersAsync();
    const result = await resultPromise;

    expect(result.success).toBe(false);
    expect(result.failureReason).toBe("FCM unavailable");
  });

  it("retry count is exactly 3 retries (4 total attempts) when all fail", async () => {
    const dispatcher = vi.fn().mockRejectedValue(new Error("network error"));

    const resultPromise = sendNotification("user-3", "Title", "Body", undefined, dispatcher);
    await vi.runAllTimersAsync();
    const result = await resultPromise;

    // 1 initial attempt + 3 retries = 4 total calls
    expect(dispatcher).toHaveBeenCalledTimes(4);
    expect(result.attempts).toBe(4);
    expect(result.success).toBe(false);
  });

  it("succeeds on retry and returns correct attempt count", async () => {
    const dispatcher = vi
      .fn()
      .mockRejectedValueOnce(new Error("transient"))
      .mockRejectedValueOnce(new Error("transient"))
      .mockResolvedValue(undefined);

    const resultPromise = sendNotification("user-4", "Title", "Body", undefined, dispatcher);
    await vi.runAllTimersAsync();
    const result = await resultPromise;

    expect(result.success).toBe(true);
    expect(result.attempts).toBe(3);
    expect(dispatcher).toHaveBeenCalledTimes(3);
  });

  it("log records all attempts for a successful first-try dispatch", async () => {
    const dispatcher = vi.fn().mockResolvedValue(undefined);

    const resultPromise = sendNotification("user-5", "Job Confirmed", "Your job is confirmed", undefined, dispatcher);
    await vi.runAllTimersAsync();
    await resultPromise;

    const log = getNotificationLog();
    expect(log).toHaveLength(1);
    expect(log[0].userId).toBe("user-5");
    expect(log[0].attempt).toBe(1);
    expect(log[0].success).toBe(true);
  });

  it("log records all 4 attempts when all fail", async () => {
    const dispatcher = vi.fn().mockRejectedValue(new Error("fail"));

    const resultPromise = sendNotification("user-6", "Title", "Body", undefined, dispatcher);
    await vi.runAllTimersAsync();
    await resultPromise;

    const log = getNotificationLog();
    expect(log).toHaveLength(4);
    expect(log.every((e) => e.success === false)).toBe(true);
    expect(log.map((e) => e.attempt)).toEqual([1, 2, 3, 4]);
  });

  it("log accumulates entries across multiple sendNotification calls", async () => {
    const ok = vi.fn().mockResolvedValue(undefined);
    const fail = vi.fn().mockRejectedValue(new Error("x"));

    const p1 = sendNotification("u1", "T", "B", undefined, ok);
    await vi.runAllTimersAsync();
    await p1;

    const p2 = sendNotification("u2", "T", "B", undefined, fail);
    await vi.runAllTimersAsync();
    await p2;

    const log = getNotificationLog();
    // 1 success + 4 failures
    expect(log).toHaveLength(5);
  });
});
