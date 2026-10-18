// Worker App — Job feed + Proof upload logic
// Requirements: 8.1, 8.2, 8.3, 8.4 (job feed)
//               6.1, 6.2, 6.4, 6.5 (proof upload)

function authHeaders(token: string): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  };
}

// ── Job feed (20.2) ──────────────────────────────────────────────────────────

/**
 * Fetch available jobs for the worker's zone.
 * GET ${apiBase}/available-jobs
 */
export async function getAvailableJobs(apiBase: string, token: string): Promise<unknown[]> {
  const res = await fetch(`${apiBase}/available-jobs`, {
    headers: authHeaders(token),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Get available jobs failed: ${res.status}`);
  }
  return res.json();
}

/**
 * Accept a job.
 * POST ${apiBase}/jobs/${jobId}/accept
 */
export async function acceptJob(
  jobId: string,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/jobs/${jobId}/accept`, {
    method: "POST",
    headers: authHeaders(token),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Accept job failed: ${res.status}`);
  }
}

/**
 * Reject a job.
 * POST ${apiBase}/jobs/${jobId}/reject
 */
export async function rejectJob(
  jobId: string,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/jobs/${jobId}/reject`, {
    method: "POST",
    headers: authHeaders(token),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Reject job failed: ${res.status}`);
  }
}

// ── Proof upload (20.3) ──────────────────────────────────────────────────────

/**
 * Start a job with a before photo.
 * POST ${apiBase}/jobs/${jobId}/start
 */
export async function startJob(
  jobId: string,
  beforePhotoUrl: string,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/jobs/${jobId}/start`, {
    method: "POST",
    headers: authHeaders(token),
    body: JSON.stringify({ before_photo_url: beforePhotoUrl }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Start job failed: ${res.status}`);
  }
}

/**
 * Complete a job with an after photo.
 * POST ${apiBase}/jobs/${jobId}/complete
 */
export async function completeJob(
  jobId: string,
  afterPhotoUrl: string,
  apiBase: string,
  token: string
): Promise<void> {
  const res = await fetch(`${apiBase}/jobs/${jobId}/complete`, {
    method: "POST",
    headers: authHeaders(token),
    body: JSON.stringify({ after_photo_url: afterPhotoUrl }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error?.message ?? `Complete job failed: ${res.status}`);
  }
}
