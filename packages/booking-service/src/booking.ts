import { randomUUID } from "crypto";
import type { Job, JobLocation } from "@ecomins/shared";

// --- In-memory store ---

const jobStore = new Map<string, Job>();

// --- Types ---

export interface CustomerProfile {
  id: string;
  name?: string;
  address?: string;
}

export interface CreateJobInput {
  service_type: string;
  location: JobLocation;
  zone_id: string;
  customer_id: string;
  price?: number;
  scheduled_time?: string;
  photo_url?: string;
}

export type CreateJobResult =
  | { success: true; job: Job }
  | { success: false; status: 400; code: string; message: string };

export interface ImageValidationResult {
  valid: boolean;
  error?: string;
}

export interface CustomerProfileValidationResult {
  valid: boolean;
  error?: string;
}

// --- Core logic functions (exported for testing) ---

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png"];
const MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024; // 10MB

/**
 * Validate an image upload by MIME type and size.
 * Requirements: 3.2, 3.3, 6.3
 */
export function validateImage(mimeType: string, sizeBytes: number): ImageValidationResult {
  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    return {
      valid: false,
      error: `Invalid file type "${mimeType}". Only JPEG and PNG images are accepted.`,
    };
  }
  if (sizeBytes > MAX_IMAGE_SIZE_BYTES) {
    return {
      valid: false,
      error: `File size ${sizeBytes} bytes exceeds the maximum allowed size of 10MB (${MAX_IMAGE_SIZE_BYTES} bytes).`,
    };
  }
  return { valid: true };
}

/**
 * Validate that a customer profile has name and address before their first booking.
 * Requirements: 1.6
 */
export function validateCustomerProfile(
  profile: CustomerProfile
): CustomerProfileValidationResult {
  if (!profile.name || profile.name.trim() === "") {
    return { valid: false, error: "Customer name is required before making a booking." };
  }
  if (!profile.address || profile.address.trim() === "") {
    return { valid: false, error: "Customer address is required before making a booking." };
  }
  return { valid: true };
}

/**
 * Create a new Job with status "pending".
 * Validates required fields, then creates the job record.
 * Requirements: 3.5, 3.6
 */
export function createJob(input: CreateJobInput): CreateJobResult {
  const { service_type, location, zone_id, customer_id, price, scheduled_time } = input;

  // Validate required fields
  if (!service_type || typeof service_type !== "string" || service_type.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "service_type is required" };
  }
  if (!customer_id || typeof customer_id !== "string" || customer_id.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "customer_id is required" };
  }
  if (!zone_id || typeof zone_id !== "string" || zone_id.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "zone_id is required" };
  }
  if (!location || typeof location !== "object") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "location is required" };
  }
  if (typeof location.lat !== "number") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "location.lat is required" };
  }
  if (typeof location.lng !== "number") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "location.lng is required" };
  }
  if (!location.address || typeof location.address !== "string" || location.address.trim() === "") {
    return { success: false, status: 400, code: "INVALID_INPUT", message: "location.address is required" };
  }

  const now = new Date().toISOString();
  const job: Job = {
    id: randomUUID(),
    customer_id: customer_id.trim(),
    worker_id: null,
    service_type: service_type.trim(),
    status: "pending",
    location: {
      lat: location.lat,
      lng: location.lng,
      address: location.address.trim(),
    },
    zone_id: zone_id.trim(),
    scheduled_time: scheduled_time ?? null,
    before_photo_url: null,
    after_photo_url: null,
    price: typeof price === "number" ? price : 0,
    created_at: now,
    updated_at: now,
  };

  jobStore.set(job.id, job);
  return { success: true, job };
}

/**
 * Get a Job by ID.
 */
export function getJob(id: string): Job | undefined {
  return jobStore.get(id);
}

// --- State machine ---

type JobStatus = Job["status"];

const VALID_TRANSITIONS: Record<string, JobStatus[]> = {
  pending: ["assigned", "in_progress", "cancelled"],
  assigned: ["en_route", "in_progress", "cancelled"],
  en_route: ["in_progress", "cancelled"],
  in_progress: ["completed", "cancelled"],
  completed: [],
  cancelled: [],
};

export type TransitionError = {
  success: false;
  status: 400 | 409;
  code: string;
  message: string;
  currentStatus?: JobStatus;
  allowedTransitions?: JobStatus[];
};

export type TransitionSuccess = {
  success: true;
  job: Job;
  earningsTriggered?: boolean;
};

export type TransitionResult = TransitionSuccess | TransitionError;

function getJobOrError(jobId: string): Job | TransitionError {
  const job = jobStore.get(jobId);
  if (!job) {
    return { success: false, status: 409, code: "JOB_NOT_FOUND", message: `Job ${jobId} not found` };
  }
  return job;
}

function assertTransition(job: Job, target: JobStatus): TransitionError | null {
  const allowed = VALID_TRANSITIONS[job.status] ?? [];
  if (!allowed.includes(target)) {
    return {
      success: false,
      status: 409,
      code: "INVALID_TRANSITION",
      message: `Cannot transition job from "${job.status}" to "${target}".`,
      currentStatus: job.status,
      allowedTransitions: allowed,
    };
  }
  return null;
}

function applyTransition(job: Job, patch: Partial<Job>): Job {
  const updated: Job = { ...job, ...patch, updated_at: new Date().toISOString() };
  jobStore.set(job.id, updated);
  return updated;
}

/**
 * Assign a job to a worker: pending → assigned.
 * Requirements: 4.3
 */
export function assignJob(jobId: string, workerId: string): TransitionResult {
  const job = getJobOrError(jobId);
  if (!("id" in job)) return job;
  const err = assertTransition(job, "assigned");
  if (err) return err;
  return { success: true, job: applyTransition(job, { status: "assigned", worker_id: workerId }) };
}

/**
 * Mark a job as en_route: assigned → en_route.
 * Requirements: 8.3
 */
export function setEnRoute(jobId: string): TransitionResult {
  const job = getJobOrError(jobId);
  if (!("id" in job)) return job;
  const err = assertTransition(job, "en_route");
  if (err) return err;
  return { success: true, job: applyTransition(job, { status: "en_route" }) };
}

/**
 * Start a job: pending | assigned | en_route → in_progress.
 * Requires before_photo_url.
 * Requirements: 6.1, 5.5
 */
export function startJob(jobId: string, beforePhotoUrl: string | undefined | null): TransitionResult {
  if (!beforePhotoUrl || beforePhotoUrl.trim() === "") {
    return { success: false, status: 400, code: "PHOTO_REQUIRED", message: "before_photo_url is required to start a job." };
  }
  const job = getJobOrError(jobId);
  if (!("id" in job)) return job;
  const err = assertTransition(job, "in_progress");
  if (err) return err;
  return { success: true, job: applyTransition(job, { status: "in_progress", before_photo_url: beforePhotoUrl.trim() }) };
}

/**
 * Complete a job: in_progress → completed.
 * Requires after_photo_url. Emits earnings trigger (stub).
 * Requirements: 6.2, 6.6, 5.5
 */
export function completeJob(jobId: string, afterPhotoUrl: string | undefined | null): TransitionResult {
  if (!afterPhotoUrl || afterPhotoUrl.trim() === "") {
    return { success: false, status: 400, code: "PHOTO_REQUIRED", message: "after_photo_url is required to complete a job." };
  }
  const job = getJobOrError(jobId);
  if (!("id" in job)) return job;
  const err = assertTransition(job, "completed");
  if (err) return err;
  return {
    success: true,
    job: applyTransition(job, { status: "completed", after_photo_url: afterPhotoUrl.trim() }),
    earningsTriggered: true,
  };
}

/**
 * Cancel a job: any non-completed state → cancelled.
 * Requires reason.
 * Requirements: 5.5
 */
export function cancelJob(jobId: string, reason: string | undefined | null): TransitionResult {
  if (!reason || reason.trim() === "") {
    return { success: false, status: 400, code: "REASON_REQUIRED", message: "reason is required to cancel a job." };
  }
  const job = getJobOrError(jobId);
  if (!("id" in job)) return job;
  const err = assertTransition(job, "cancelled");
  if (err) return err;
  return { success: true, job: applyTransition(job, { status: "cancelled" }) };
}

// --- Store helpers for testing ---

export function _clearJobStore(): void {
  jobStore.clear();
}

export function _getJobStore(): Map<string, Job> {
  return jobStore;
}
