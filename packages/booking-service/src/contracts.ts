import { randomUUID } from "crypto";
import type { B2BContract, Job } from "@ecomins/shared";

// --- In-memory store ---

const contractStore = new Map<string, B2BContract>();

// --- Types ---

export interface CreateContractInput {
  client_name: string;
  service_scope: string;
  zone_id: string;
  start_date: string;
  end_date: string;
  monthly_rate: number;
  recurrence_schedule: string;
}

export type CreateContractResult =
  | { success: true; contract: B2BContract }
  | { success: false; status: 400; code: string; message: string };

// Required string fields for validation
const REQUIRED_STRING_FIELDS: (keyof CreateContractInput)[] = [
  "client_name",
  "service_scope",
  "zone_id",
  "start_date",
  "end_date",
  "recurrence_schedule",
];

/**
 * Create a new B2B contract.
 * Validates all required fields; returns 400 if any are missing/empty.
 * Requirements: 17.1
 */
export function createContract(input: CreateContractInput): CreateContractResult {
  // Validate string fields
  for (const field of REQUIRED_STRING_FIELDS) {
    const value = input[field];
    if (!value || typeof value !== "string" || (value as string).trim() === "") {
      return {
        success: false,
        status: 400,
        code: "INVALID_INPUT",
        message: `${field} is required`,
      };
    }
  }

  // Validate monthly_rate
  if (typeof input.monthly_rate !== "number" || isNaN(input.monthly_rate)) {
    return {
      success: false,
      status: 400,
      code: "INVALID_INPUT",
      message: "monthly_rate is required",
    };
  }

  const contract: B2BContract = {
    id: randomUUID(),
    client_name: input.client_name.trim(),
    service_scope: input.service_scope.trim(),
    zone_id: input.zone_id.trim(),
    start_date: input.start_date.trim(),
    end_date: input.end_date.trim(),
    monthly_rate: input.monthly_rate,
    recurrence_schedule: input.recurrence_schedule.trim(),
    status: "active",
  };

  contractStore.set(contract.id, contract);
  return { success: true, contract };
}

/**
 * Return all contracts.
 * Requirements: 17.4
 */
export function getContracts(): B2BContract[] {
  return Array.from(contractStore.values());
}

/**
 * Return a contract by ID, or null if not found.
 * Requirements: 17.4
 */
export function getContractById(id: string): B2BContract | null {
  return contractStore.get(id) ?? null;
}

/**
 * Mark contracts as "expired" where end_date < now.
 * Requirements: 17.3
 */
export function checkAndExpireContracts(now: Date): void {
  for (const contract of contractStore.values()) {
    if (contract.status === "active" && new Date(contract.end_date) < now) {
      contractStore.set(contract.id, { ...contract, status: "expired" });
    }
  }
}

/**
 * For each active contract, call createJobFn with the contract details.
 * Stub — does not implement real cron scheduling.
 * Requirements: 17.2
 */
export function generateJobsForActiveContracts(
  now: Date,
  createJobFn: (contract: B2BContract) => void
): void {
  for (const contract of contractStore.values()) {
    if (contract.status === "active") {
      createJobFn(contract);
    }
  }
}

// --- Store helpers for testing ---

export function _clearContractStore(): void {
  contractStore.clear();
}
