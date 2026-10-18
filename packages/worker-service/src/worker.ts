import { randomUUID } from "crypto";
import type { Worker, KYCSubmission } from "@ecomins/shared";

// --- In-memory stores ---

const workerStore = new Map<string, Worker & { name: string; phone: string }>();
const kycStore = new Map<string, KYCSubmission>();

// --- Types ---

export interface CreateWorkerInput {
  name: string;
  phone: string;
  zone_id: string;
  skills: string[];
}

export interface WorkerRecord extends Worker {
  name: string;
  phone: string;
}

export type CreateWorkerResult =
  | { success: true; worker: WorkerRecord }
  | { success: false; status: 400; code: string; message: string };

export type GetWorkerResult =
  | { success: true; worker: WorkerRecord }
  | { success: false; status: 404; code: string; message: string };

export type UpdateAvailabilityResult =
  | { success: true; worker: WorkerRecord }
  | { success: false; status: 404; code: string; message: string };

export type SubmitKycResult =
  | { success: true; submission: KYCSubmission }
  | { success: false; status: 400 | 404; code: string; message: string };

export type ReviewKycResult =
  | { success: true; worker: WorkerRecord; submission: KYCSubmission }
  | { success: false; status: 400 | 404; code: string; message: string };

export type UpdateZoneResult =
  | { success: true; worker: WorkerRecord }
  | { success: false; status: 400 | 404; code: string; message: string };

// --- Core logic functions (exported for testing) ---

/**
 * Create a new Worker record. Validates required fields.
 * Requirements: 7.1, 11.2
 */
export function createWorker(input: CreateWorkerInput): CreateWorkerResult {
  const { name, phone, zone_id, skills } = input;

  if (!name || typeof name !== "string" || name.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "name is required" };
  }
  if (!phone || typeof phone !== "string" || phone.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "phone is required" };
  }
  if (!zone_id || typeof zone_id !== "string" || zone_id.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "zone_id is required" };
  }
  if (!Array.isArray(skills) || skills.length === 0) {
    return {
      success: false,
      status: 400,
      code: "INVALID_INPUT",
      message: "skills must be a non-empty array",
    };
  }

  const worker: WorkerRecord = {
    id: randomUUID(),
    name: name.trim(),
    phone: phone.trim(),
    zone_id: zone_id.trim(),
    skills,
    availability: true,
    kyc_status: "pending",
    rating: 0,
    total_jobs: 0,
  };

  workerStore.set(worker.id, worker);
  return { success: true, worker };
}

/**
 * Get a Worker by ID.
 */
export function getWorker(id: string): GetWorkerResult {
  const worker = workerStore.get(id);
  if (!worker) {
    return { success: false, status: 404, code: "NOT_FOUND", message: "Worker not found" };
  }
  return { success: true, worker };
}

/**
 * Update a Worker's availability immediately.
 * Requirements: 8.5, 8.6
 */
export function updateAvailability(id: string, available: boolean): UpdateAvailabilityResult {
  const worker = workerStore.get(id);
  if (!worker) {
    return { success: false, status: 404, code: "NOT_FOUND", message: "Worker not found" };
  }
  worker.availability = available;
  workerStore.set(id, worker);
  return { success: true, worker };
}

/**
 * Submit KYC documents for a Worker — creates a KYCSubmission with status "pending".
 * Requirements: 7.2
 */
export function submitKyc(
  workerId: string,
  input: { id_document_url: string; selfie_url: string }
): SubmitKycResult {
  const worker = workerStore.get(workerId);
  if (!worker) {
    return { success: false, status: 404, code: "NOT_FOUND", message: "Worker not found" };
  }

  if (!input.id_document_url || !input.selfie_url) {
    return {
      success: false,
      status: 400,
      code: "INVALID_INPUT",
      message: "id_document_url and selfie_url are required",
    };
  }

  const submission: KYCSubmission = {
    id: randomUUID(),
    worker_id: workerId,
    id_document_url: input.id_document_url,
    selfie_url: input.selfie_url,
    status: "pending",
    reviewed_by: null,
    rejection_reason: null,
    submitted_at: new Date().toISOString(),
    reviewed_at: null,
  };

  kycStore.set(submission.id, submission);
  return { success: true, submission };
}

/**
 * Admin reviews a KYC submission — approves or rejects.
 * On approval: sets worker kyc_status to "verified".
 * On rejection: sets worker kyc_status to "rejected", requires a reason.
 * Requirements: 7.4, 7.5
 */
export function reviewKyc(
  workerId: string,
  input: { approved: boolean; reason?: string; reviewed_by?: string }
): ReviewKycResult {
  const worker = workerStore.get(workerId);
  if (!worker) {
    return { success: false, status: 404, code: "NOT_FOUND", message: "Worker not found" };
  }

  // Find the latest pending KYC submission for this worker
  const submissions = Array.from(kycStore.values())
    .filter((s) => s.worker_id === workerId && s.status === "pending")
    .sort((a, b) => new Date(b.submitted_at).getTime() - new Date(a.submitted_at).getTime());

  if (submissions.length === 0) {
    return {
      success: false,
      status: 404,
      code: "NOT_FOUND",
      message: "No pending KYC submission found for this worker",
    };
  }

  if (!input.approved && (!input.reason || input.reason.trim() === "")) {
    return {
      success: false,
      status: 400,
      code: "INVALID_INPUT",
      message: "rejection reason is required when rejecting KYC",
    };
  }

  const submission = submissions[0];
  const now = new Date().toISOString();

  if (input.approved) {
    submission.status = "approved";
    worker.kyc_status = "verified";
  } else {
    submission.status = "rejected";
    submission.rejection_reason = input.reason!.trim();
    worker.kyc_status = "rejected";
  }

  submission.reviewed_by = input.reviewed_by ?? null;
  submission.reviewed_at = now;

  kycStore.set(submission.id, submission);
  workerStore.set(workerId, worker);

  return { success: true, worker, submission };
}

/**
 * Update a Worker's zone assignment.
 * Requirements: 11.4
 */
export function updateZone(workerId: string, zone_id: string): UpdateZoneResult {
  if (!zone_id || typeof zone_id !== "string" || zone_id.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "zone_id is required" };
  }

  const worker = workerStore.get(workerId);
  if (!worker) {
    return { success: false, status: 404, code: "NOT_FOUND", message: "Worker not found" };
  }

  worker.zone_id = zone_id.trim();
  workerStore.set(workerId, worker);
  return { success: true, worker };
}

// --- Store helpers for testing ---

export function _clearWorkerStore(): void {
  workerStore.clear();
}

export function _clearKycStore(): void {
  kycStore.clear();
}

export function _getWorkerStore(): Map<string, WorkerRecord> {
  return workerStore;
}

export function _getKycStore(): Map<string, KYCSubmission> {
  return kycStore;
}
