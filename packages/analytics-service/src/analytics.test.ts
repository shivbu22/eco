import { describe, it, expect, beforeEach } from "vitest";
import { addJobRecord, getSummary, exportCsv, _clearStore } from "./analytics";
import type { Job } from "@ecomins/shared";

function makeJob(overrides: Partial<Job> = {}): Job {
  return {
    id: "job-1",
    customer_id: "cust-1",
    worker_id: "worker-1",
    service_type: "cleaning",
    status: "completed",
    location: { lat: 0, lng: 0, address: "Test St" },
    zone_id: "zone-a",
    scheduled_time: null,
    before_photo_url: null,
    after_photo_url: null,
    price: 100,
    created_at: "2024-06-15T10:00:00Z",
    updated_at: "2024-06-15T11:00:00Z",
    ...overrides,
  };
}

beforeEach(() => {
  _clearStore();
});

describe("getSummary", () => {
  it("returns correct totals for unfiltered data", () => {
    addJobRecord(makeJob({ id: "j1", worker_id: "w1", price: 200 }));
    addJobRecord(makeJob({ id: "j2", worker_id: "w2", price: 300 }));
    addJobRecord(makeJob({ id: "j3", worker_id: "w1", price: 100 }));

    const summary = getSummary();

    expect(summary.total_jobs_completed).toBe(3);
    expect(summary.total_revenue).toBe(600);
    // w1 and w2 are unique workers
    expect(summary.active_worker_count).toBe(2);
  });

  it("excludes non-completed jobs from totals", () => {
    addJobRecord(makeJob({ id: "j1", status: "completed", price: 100 }));
    addJobRecord(makeJob({ id: "j2", status: "pending", price: 200 }));
    addJobRecord(makeJob({ id: "j3", status: "cancelled", price: 150 }));

    const summary = getSummary();

    expect(summary.total_jobs_completed).toBe(1);
    expect(summary.total_revenue).toBe(100);
  });

  it("filters by date range — only jobs within range are included", () => {
    addJobRecord(makeJob({ id: "j1", created_at: "2024-06-01T00:00:00Z", price: 100 }));
    addJobRecord(makeJob({ id: "j2", created_at: "2024-06-15T00:00:00Z", price: 200 }));
    addJobRecord(makeJob({ id: "j3", created_at: "2024-06-30T00:00:00Z", price: 300 }));

    const summary = getSummary({ from: "2024-06-10T00:00:00Z", to: "2024-06-20T00:00:00Z" });

    expect(summary.total_jobs_completed).toBe(1);
    expect(summary.total_revenue).toBe(200);
  });

  it("filters by zone_id", () => {
    addJobRecord(makeJob({ id: "j1", zone_id: "zone-a", price: 100 }));
    addJobRecord(makeJob({ id: "j2", zone_id: "zone-b", price: 200 }));
    addJobRecord(makeJob({ id: "j3", zone_id: "zone-a", price: 50 }));

    const summary = getSummary({ zone_id: "zone-a" });

    expect(summary.total_jobs_completed).toBe(2);
    expect(summary.total_revenue).toBe(150);
  });

  it("filters by service_type", () => {
    addJobRecord(makeJob({ id: "j1", service_type: "cleaning", price: 100 }));
    addJobRecord(makeJob({ id: "j2", service_type: "recycling", price: 200 }));
    addJobRecord(makeJob({ id: "j3", service_type: "cleaning", price: 80 }));

    const summary = getSummary({ service_type: "cleaning" });

    expect(summary.total_jobs_completed).toBe(2);
    expect(summary.total_revenue).toBe(180);
  });

  it("returns zeros when no jobs match filters", () => {
    addJobRecord(makeJob({ id: "j1", zone_id: "zone-a" }));

    const summary = getSummary({ zone_id: "zone-z" });

    expect(summary.total_jobs_completed).toBe(0);
    expect(summary.total_revenue).toBe(0);
    expect(summary.active_worker_count).toBe(0);
  });
});

describe("exportCsv", () => {
  it("returns a valid CSV string with header and data rows", () => {
    addJobRecord(makeJob({ id: "j1", price: 100 }));
    addJobRecord(makeJob({ id: "j2", price: 200 }));

    const csv = exportCsv();
    const lines = csv.split("\n");

    // Header row
    expect(lines[0]).toBe("id,customer_id,worker_id,service_type,status,zone_id,price,created_at,updated_at");
    // Two data rows
    expect(lines).toHaveLength(3);
    expect(lines[1]).toContain("j1");
    expect(lines[2]).toContain("j2");
  });

  it("returns only header when no jobs match", () => {
    const csv = exportCsv();
    const lines = csv.split("\n");

    expect(lines).toHaveLength(1);
    expect(lines[0]).toContain("id");
  });

  it("respects date range filter", () => {
    addJobRecord(makeJob({ id: "j1", created_at: "2024-05-01T00:00:00Z" }));
    addJobRecord(makeJob({ id: "j2", created_at: "2024-06-15T00:00:00Z" }));
    addJobRecord(makeJob({ id: "j3", created_at: "2024-07-01T00:00:00Z" }));

    const csv = exportCsv({ from: "2024-06-01T00:00:00Z", to: "2024-06-30T00:00:00Z" });
    const lines = csv.split("\n");

    // Header + 1 data row
    expect(lines).toHaveLength(2);
    expect(lines[1]).toContain("j2");
  });

  it("escapes fields containing commas", () => {
    addJobRecord(makeJob({ id: "j1", service_type: "cleaning,waste" }));

    const csv = exportCsv();
    const lines = csv.split("\n");

    expect(lines[1]).toContain('"cleaning,waste"');
  });
});
