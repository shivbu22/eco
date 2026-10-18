// Admin Panel — Job management logic
// Requirements: 10.1, 10.2, 10.3, 10.4, 10.5

async function handleResponse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({ error: { message: `HTTP ${res.status}` } }));
    throw new Error(body?.error?.message ?? `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
}

const authHeaders = (token: string) => ({
  Authorization: `Bearer ${token}`,
  "Content-Type": "application/json",
});

/** GET /jobs — list all jobs, optionally filtered by status (Req 10.3, 10.4) */
export async function getJobs(
  filters: { status?: string },
  apiBase: string,
  token: string
): Promise<unknown[]> {
  const url = new URL(`${apiBase}/jobs`);
  if (filters.status) url.searchParams.set("status", filters.status);
  const res = await fetch(url.toString(), { headers: authHeaders(token) });
  return handleResponse<unknown[]>(res);
}

/** POST /jobs — manually create a job (Req 10.1) */
export async function createJob(
  input: { service_type: string; location: string; scheduled_time: string },
  apiBase: string,
  token: string
): Promise<{ job_id: string }> {
  const res = await fetch(`${apiBase}/jobs`, {
    method: "POST",
    headers: authHeaders(token),
    body: JSON.stringify(input),
  });
  return handleResponse<{ job_id: string }>(res);
}

/** POST /assign-worker — manually assign a worker to a job (Req 10.2) */
export async function assignWorker(
  jobId: string,
  workerId: string,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/assign-worker`, {
    method: "POST",
    headers: authHeaders(token),
    body: JSON.stringify({ job_id: jobId, worker_id: workerId }),
  });
  return handleResponse<unknown>(res);
}

/** PATCH /jobs/:id — update job status with mandatory reason (Req 10.5) */
export async function updateJobStatus(
  jobId: string,
  status: string,
  reason: string,
  apiBase: string,
  token: string
): Promise<unknown> {
  const res = await fetch(`${apiBase}/jobs/${jobId}`, {
    method: "PATCH",
    headers: authHeaders(token),
    body: JSON.stringify({ status, reason }),
  });
  return handleResponse<unknown>(res);
}
