// Customer App — Booking flow logic
// Requirements: 3.1, 3.2, 3.3, 3.5, 3.6

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png"];
const MAX_SIZE_BYTES = 10 * 1024 * 1024; // 10 MB

export interface PhotoValidationResult {
  valid: boolean;
  error?: string;
}

/**
 * Validate a photo before upload.
 * Requirement 3.2: accept JPEG/PNG ≤ 10MB.
 * Requirement 3.3: reject anything else with a descriptive error.
 */
export function validateBookingPhoto(
  mimeType: string,
  sizeBytes: number
): PhotoValidationResult {
  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    return {
      valid: false,
      error: `Invalid file type "${mimeType}". Only JPEG and PNG images are accepted.`,
    };
  }
  if (sizeBytes > MAX_SIZE_BYTES) {
    return {
      valid: false,
      error: `File size ${sizeBytes} bytes exceeds the 10 MB limit.`,
    };
  }
  return { valid: true };
}

export interface BookingInput {
  serviceType: string;
  location: { lat: number; lng: number; address: string };
  photoUrl?: string;
  scheduledTime?: string;
}

export interface BookingResult {
  jobId: string;
}

/**
 * Submit a booking to the API.
 * Requirement 3.6: POST to ${apiBase}/jobs, return job_id.
 */
export async function submitBooking(
  input: BookingInput,
  apiBase: string,
  token: string
): Promise<BookingResult> {
  const res = await fetch(`${apiBase}/jobs`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      service_type: input.serviceType,
      location: input.location,
      photo_url: input.photoUrl,
      scheduled_time: input.scheduledTime,
    }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Submit booking failed: ${res.status}`);
  }
  const data = await res.json();
  return { jobId: data.job_id };
}
