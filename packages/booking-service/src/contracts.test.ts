import { describe, it, expect, beforeEach } from "vitest";
import {
  createContract,
  getContracts,
  getContractById,
  checkAndExpireContracts,
  generateJobsForActiveContracts,
  _clearContractStore,
} from "./contracts";
import type { B2BContract } from "@ecomins/shared";

const VALID_INPUT = {
  client_name: "Acme Corp",
  service_scope: "weekly cleaning",
  zone_id: "zone-1",
  start_date: "2024-01-01",
  end_date: "2024-12-31",
  monthly_rate: 5000,
  recurrence_schedule: "0 8 * * 1",
};

beforeEach(() => {
  _clearContractStore();
});

describe("createContract", () => {
  it("succeeds with all valid fields", () => {
    const result = createContract(VALID_INPUT);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.contract.client_name).toBe("Acme Corp");
      expect(result.contract.status).toBe("active");
      expect(result.contract.id).toBeTruthy();
    }
  });

  it("returns 400 when client_name is missing", () => {
    const result = createContract({ ...VALID_INPUT, client_name: "" });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(400);
      expect(result.message).toMatch(/client_name/);
    }
  });

  it("returns 400 when service_scope is missing", () => {
    const result = createContract({ ...VALID_INPUT, service_scope: "" });
    expect(result.success).toBe(false);
    if (!result.success) expect(result.status).toBe(400);
  });

  it("returns 400 when zone_id is missing", () => {
    const result = createContract({ ...VALID_INPUT, zone_id: "   " });
    expect(result.success).toBe(false);
    if (!result.success) expect(result.status).toBe(400);
  });

  it("returns 400 when start_date is missing", () => {
    const result = createContract({ ...VALID_INPUT, start_date: "" });
    expect(result.success).toBe(false);
    if (!result.success) expect(result.status).toBe(400);
  });

  it("returns 400 when end_date is missing", () => {
    const result = createContract({ ...VALID_INPUT, end_date: "" });
    expect(result.success).toBe(false);
    if (!result.success) expect(result.status).toBe(400);
  });

  it("returns 400 when recurrence_schedule is missing", () => {
    const result = createContract({ ...VALID_INPUT, recurrence_schedule: "" });
    expect(result.success).toBe(false);
    if (!result.success) expect(result.status).toBe(400);
  });

  it("returns 400 when monthly_rate is not a number", () => {
    const result = createContract({ ...VALID_INPUT, monthly_rate: NaN });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.status).toBe(400);
      expect(result.message).toMatch(/monthly_rate/);
    }
  });
});

describe("getContracts", () => {
  it("returns empty array when no contracts exist", () => {
    expect(getContracts()).toEqual([]);
  });

  it("returns all stored contracts", () => {
    createContract(VALID_INPUT);
    createContract({ ...VALID_INPUT, client_name: "Beta Ltd" });
    const contracts = getContracts();
    expect(contracts).toHaveLength(2);
    const names = contracts.map((c) => c.client_name);
    expect(names).toContain("Acme Corp");
    expect(names).toContain("Beta Ltd");
  });
});

describe("getContractById", () => {
  it("returns the contract for a valid id", () => {
    const result = createContract(VALID_INPUT);
    if (!result.success) throw new Error("setup failed");
    const found = getContractById(result.contract.id);
    expect(found).not.toBeNull();
    expect(found?.id).toBe(result.contract.id);
  });

  it("returns null for an unknown id", () => {
    expect(getContractById("nonexistent-id")).toBeNull();
  });
});

describe("checkAndExpireContracts", () => {
  it("marks contracts whose end_date is in the past as expired", () => {
    createContract({ ...VALID_INPUT, end_date: "2020-01-01" });
    checkAndExpireContracts(new Date("2024-01-01"));
    const contracts = getContracts();
    expect(contracts[0].status).toBe("expired");
  });

  it("does not expire contracts whose end_date is in the future", () => {
    createContract({ ...VALID_INPUT, end_date: "2099-12-31" });
    checkAndExpireContracts(new Date());
    const contracts = getContracts();
    expect(contracts[0].status).toBe("active");
  });

  it("does not re-expire already expired contracts", () => {
    createContract({ ...VALID_INPUT, end_date: "2020-01-01" });
    checkAndExpireContracts(new Date("2024-01-01"));
    checkAndExpireContracts(new Date("2025-01-01"));
    const contracts = getContracts();
    expect(contracts[0].status).toBe("expired");
  });
});

describe("generateJobsForActiveContracts", () => {
  it("calls createJobFn for each active contract", () => {
    createContract(VALID_INPUT);
    createContract({ ...VALID_INPUT, client_name: "Beta Ltd" });
    const called: B2BContract[] = [];
    generateJobsForActiveContracts(new Date(), (c) => called.push(c));
    expect(called).toHaveLength(2);
  });

  it("does not call createJobFn for expired contracts", () => {
    createContract({ ...VALID_INPUT, end_date: "2020-01-01" });
    checkAndExpireContracts(new Date("2024-01-01"));
    const called: B2BContract[] = [];
    generateJobsForActiveContracts(new Date(), (c) => called.push(c));
    expect(called).toHaveLength(0);
  });

  it("passes the correct contract to createJobFn", () => {
    const result = createContract(VALID_INPUT);
    if (!result.success) throw new Error("setup failed");
    let received: B2BContract | null = null;
    generateJobsForActiveContracts(new Date(), (c) => { received = c; });
    expect(received).not.toBeNull();
    expect((received as unknown as B2BContract).id).toBe(result.contract.id);
  });
});
