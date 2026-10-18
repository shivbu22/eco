import { describe, it, expect, vi, afterEach } from "vitest";
import {
  connectToJobTracking,
  disconnectFromJobTracking,
  isTrackingActive,
} from "./tracking";

afterEach(() => {
  // Clean up any active connections
  disconnectFromJobTracking("job-1");
  disconnectFromJobTracking("job-2");
  vi.useRealTimers();
});

describe("connectToJobTracking", () => {
  it("calls onLocation immediately with coordinates", () => {
    vi.useFakeTimers();
    const onLocation = vi.fn();
    connectToJobTracking("job-1", onLocation);
    expect(onLocation).toHaveBeenCalledOnce();
    const [lat, lng] = onLocation.mock.calls[0];
    expect(typeof lat).toBe("number");
    expect(typeof lng).toBe("number");
  });

  it("marks the connection as active", () => {
    vi.useFakeTimers();
    connectToJobTracking("job-1", vi.fn());
    expect(isTrackingActive("job-1")).toBe(true);
  });

  it("does not create duplicate connections for the same jobId", () => {
    vi.useFakeTimers();
    const onLocation = vi.fn();
    connectToJobTracking("job-1", onLocation);
    connectToJobTracking("job-1", onLocation); // second call should be a no-op
    expect(onLocation).toHaveBeenCalledOnce(); // only the first immediate call
  });

  it("emits further location updates on interval", () => {
    vi.useFakeTimers();
    const onLocation = vi.fn();
    connectToJobTracking("job-1", onLocation);
    vi.advanceTimersByTime(10000); // advance 10s → 2 more ticks
    expect(onLocation.mock.calls.length).toBeGreaterThan(1);
  });
});

describe("disconnectFromJobTracking", () => {
  it("removes the active connection", () => {
    vi.useFakeTimers();
    connectToJobTracking("job-2", vi.fn());
    expect(isTrackingActive("job-2")).toBe(true);
    disconnectFromJobTracking("job-2");
    expect(isTrackingActive("job-2")).toBe(false);
  });

  it("is safe to call when no connection exists", () => {
    expect(() => disconnectFromJobTracking("nonexistent-job")).not.toThrow();
  });

  it("stops emitting location updates after disconnect", () => {
    vi.useFakeTimers();
    const onLocation = vi.fn();
    connectToJobTracking("job-1", onLocation);
    disconnectFromJobTracking("job-1");
    const callsAfterDisconnect = onLocation.mock.calls.length;
    vi.advanceTimersByTime(20000);
    expect(onLocation.mock.calls.length).toBe(callsAfterDisconnect);
  });
});
