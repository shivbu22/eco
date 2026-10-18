import { describe, it, expect } from "vitest";
import {
  filterEligibleWorkers,
  haversineDistance,
  findNearestWorker,
  matchJob,
  WorkerWithLocation,
} from "./matching";
import type { Job, Zone } from "@ecomins/shared";

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeWorker(overrides: Partial<WorkerWithLocation> = {}): WorkerWithLocation {
  return {
    id: "w1",
    zone_id: "zone-a",
    skills: ["cleaning"],
    availability: true,
    kyc_status: "verified",
    rating: 4.5,
    total_jobs: 10,
    lat: 0,
    lng: 0,
    ...overrides,
  };
}

function makeJob(overrides: Partial<Job> = {}): Job {
  return {
    id: "j1",
    customer_id: "c1",
    worker_id: null,
    service_type: "cleaning",
    status: "pending",
    location: { lat: 0, lng: 0, address: "Test St" },
    zone_id: "zone-a",
    scheduled_time: null,
    before_photo_url: null,
    after_photo_url: null,
    price: 100,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    ...overrides,
  };
}

// ── filterEligibleWorkers ─────────────────────────────────────────────────────

describe("filterEligibleWorkers", () => {
  it("excludes workers with unverified kyc_status", () => {
    const workers = [
      makeWorker({ id: "w1", kyc_status: "pending" }),
      makeWorker({ id: "w2", kyc_status: "rejected" }),
      makeWorker({ id: "w3", kyc_status: "verified" }),
    ];
    const result = filterEligibleWorkers(workers, makeJob());
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("w3");
  });

  it("excludes unavailable workers", () => {
    const workers = [
      makeWorker({ id: "w1", availability: false }),
      makeWorker({ id: "w2", availability: true }),
    ];
    const result = filterEligibleWorkers(workers, makeJob());
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("w2");
  });

  it("excludes workers without the required skill", () => {
    const workers = [
      makeWorker({ id: "w1", skills: ["recycling"] }),
      makeWorker({ id: "w2", skills: ["cleaning", "recycling"] }),
    ];
    const result = filterEligibleWorkers(workers, makeJob({ service_type: "cleaning" }));
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("w2");
  });

  it("returns all workers that pass all three criteria", () => {
    const workers = [
      makeWorker({ id: "w1" }),
      makeWorker({ id: "w2" }),
    ];
    const result = filterEligibleWorkers(workers, makeJob());
    expect(result).toHaveLength(2);
  });

  it("returns empty array when no workers are eligible", () => {
    const workers = [makeWorker({ kyc_status: "pending" })];
    const result = filterEligibleWorkers(workers, makeJob());
    expect(result).toHaveLength(0);
  });
});

// ── haversineDistance ─────────────────────────────────────────────────────────

describe("haversineDistance", () => {
  it("returns 0 for identical coordinates", () => {
    expect(haversineDistance(12.9716, 77.5946, 12.9716, 77.5946)).toBe(0);
  });

  it("returns approximately correct distance for known coordinates", () => {
    // Bangalore (12.9716, 77.5946) → Mumbai (19.0760, 72.8777) ≈ 845 km
    const dist = haversineDistance(12.9716, 77.5946, 19.076, 72.8777);
    expect(dist).toBeGreaterThan(830);
    expect(dist).toBeLessThan(860);
  });

  it("is symmetric — distance A→B equals B→A", () => {
    const d1 = haversineDistance(10, 20, 30, 40);
    const d2 = haversineDistance(30, 40, 10, 20);
    expect(d1).toBeCloseTo(d2, 6);
  });
});

// ── findNearestWorker ─────────────────────────────────────────────────────────

describe("findNearestWorker", () => {
  it("returns null when the list is empty", () => {
    expect(findNearestWorker([], 0, 0)).toBeNull();
  });

  it("returns the only worker when there is one", () => {
    const worker = makeWorker({ lat: 1, lng: 1 });
    expect(findNearestWorker([worker], 0, 0)).toBe(worker);
  });

  it("returns the closest worker", () => {
    const far = makeWorker({ id: "far", lat: 10, lng: 10 });
    const near = makeWorker({ id: "near", lat: 0.01, lng: 0.01 });
    const result = findNearestWorker([far, near], 0, 0);
    expect(result?.id).toBe("near");
  });

  it("handles workers at the same distance by returning one of them", () => {
    const w1 = makeWorker({ id: "w1", lat: 1, lng: 0 });
    const w2 = makeWorker({ id: "w2", lat: -1, lng: 0 });
    const result = findNearestWorker([w1, w2], 0, 0);
    expect(["w1", "w2"]).toContain(result?.id);
  });
});

// ── matchJob ──────────────────────────────────────────────────────────────────

describe("matchJob", () => {
  const zoneA: Zone = {
    id: "zone-a",
    name: "Zone A",
    center_lat: 0,
    center_lng: 0,
    radius_meters: 1000,
    adjacent_zone_ids: ["zone-b"],
  };

  const zoneB: Zone = {
    id: "zone-b",
    name: "Zone B",
    center_lat: 1,
    center_lng: 1,
    radius_meters: 1000,
    adjacent_zone_ids: ["zone-a"],
  };

  it("returns null when there are no eligible workers", () => {
    const job = makeJob();
    const workers = [makeWorker({ kyc_status: "pending" })];
    expect(matchJob(job, workers, [zoneA, zoneB])).toBeNull();
  });

  it("returns the nearest eligible worker in the same zone", () => {
    const job = makeJob({ zone_id: "zone-a", location: { lat: 0, lng: 0, address: "" } });
    const workers = [
      makeWorker({ id: "near", zone_id: "zone-a", lat: 0.001, lng: 0.001 }),
      makeWorker({ id: "far", zone_id: "zone-a", lat: 5, lng: 5 }),
    ];
    const result = matchJob(job, workers, [zoneA, zoneB]);
    expect(result?.id).toBe("near");
  });

  it("falls back to adjacent zones when primary zone has no eligible workers", () => {
    const job = makeJob({ zone_id: "zone-a", location: { lat: 0, lng: 0, address: "" } });
    // No workers in zone-a, one in zone-b (adjacent)
    const workers = [
      makeWorker({ id: "adj", zone_id: "zone-b", lat: 1, lng: 1 }),
    ];
    const result = matchJob(job, workers, [zoneA, zoneB]);
    expect(result?.id).toBe("adj");
  });

  it("returns null when no workers in primary or adjacent zones", () => {
    const job = makeJob({ zone_id: "zone-a" });
    const workers = [
      makeWorker({ id: "other", zone_id: "zone-c", lat: 50, lng: 50 }),
    ];
    const result = matchJob(job, workers, [zoneA, zoneB]);
    expect(result).toBeNull();
  });

  it("prefers primary zone worker over adjacent zone worker", () => {
    const job = makeJob({ zone_id: "zone-a", location: { lat: 0, lng: 0, address: "" } });
    const workers = [
      makeWorker({ id: "primary", zone_id: "zone-a", lat: 0.5, lng: 0.5 }),
      makeWorker({ id: "adjacent", zone_id: "zone-b", lat: 0.001, lng: 0.001 }),
    ];
    // Primary zone has an eligible worker, so adjacent should not be checked
    const result = matchJob(job, workers, [zoneA, zoneB]);
    expect(result?.id).toBe("primary");
  });
});
