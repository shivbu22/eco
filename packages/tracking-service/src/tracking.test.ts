import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  updateLocation,
  getLastLocation,
  subscribeToJob,
  unsubscribeFromJob,
  stopTracking,
} from "./tracking";

// Reset in-memory state between tests by stopping any tracked jobs
beforeEach(() => {
  // Use unique job IDs per test to avoid cross-test pollution
});

describe("updateLocation", () => {
  it("stores the latest location for a worker+job pair", () => {
    updateLocation("w1", "job-store-1", 12.34, 56.78);
    const loc = getLastLocation("job-store-1");
    expect(loc).not.toBeNull();
    expect(loc!.workerId).toBe("w1");
    expect(loc!.jobId).toBe("job-store-1");
    expect(loc!.lat).toBe(12.34);
    expect(loc!.lng).toBe(56.78);
  });

  it("overwrites the previous location with the latest one", () => {
    updateLocation("w2", "job-overwrite-1", 1.0, 2.0);
    updateLocation("w2", "job-overwrite-1", 3.0, 4.0);
    const loc = getLastLocation("job-overwrite-1");
    expect(loc!.lat).toBe(3.0);
    expect(loc!.lng).toBe(4.0);
  });
});

describe("getLastLocation", () => {
  it("returns null for an unknown job", () => {
    expect(getLastLocation("job-unknown-xyz")).toBeNull();
  });

  it("returns the stored location after an update", () => {
    updateLocation("w3", "job-get-1", 9.9, 8.8);
    expect(getLastLocation("job-get-1")).not.toBeNull();
  });
});

describe("subscribeToJob", () => {
  it("calls the callback when location updates", () => {
    const cb = vi.fn();
    subscribeToJob("job-sub-1", cb);
    updateLocation("w4", "job-sub-1", 10.0, 20.0);
    expect(cb).toHaveBeenCalledOnce();
    expect(cb).toHaveBeenCalledWith(
      expect.objectContaining({ lat: 10.0, lng: 20.0, jobId: "job-sub-1" })
    );
    stopTracking("job-sub-1");
  });

  it("calls multiple subscribers when location updates", () => {
    const cb1 = vi.fn();
    const cb2 = vi.fn();
    subscribeToJob("job-sub-2", cb1);
    subscribeToJob("job-sub-2", cb2);
    updateLocation("w5", "job-sub-2", 5.0, 6.0);
    expect(cb1).toHaveBeenCalledOnce();
    expect(cb2).toHaveBeenCalledOnce();
    stopTracking("job-sub-2");
  });
});

describe("unsubscribeFromJob", () => {
  it("removes all callbacks so they are not called on subsequent updates", () => {
    const cb = vi.fn();
    subscribeToJob("job-unsub-1", cb);
    unsubscribeFromJob("job-unsub-1");
    updateLocation("w6", "job-unsub-1", 1.0, 1.0);
    expect(cb).not.toHaveBeenCalled();
    stopTracking("job-unsub-1");
  });

  it("does not throw when unsubscribing a job with no subscribers", () => {
    expect(() => unsubscribeFromJob("job-unsub-none")).not.toThrow();
  });
});

describe("stopTracking", () => {
  it("clears the stored location", () => {
    updateLocation("w7", "job-stop-1", 7.0, 8.0);
    stopTracking("job-stop-1");
    expect(getLastLocation("job-stop-1")).toBeNull();
  });

  it("clears subscribers so callbacks are not called after stop", () => {
    const cb = vi.fn();
    subscribeToJob("job-stop-2", cb);
    stopTracking("job-stop-2");
    updateLocation("w8", "job-stop-2", 1.0, 2.0);
    expect(cb).not.toHaveBeenCalled();
    stopTracking("job-stop-2");
  });

  it("does not throw when stopping a job that was never tracked", () => {
    expect(() => stopTracking("job-stop-never")).not.toThrow();
  });
});
