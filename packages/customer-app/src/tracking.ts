// Customer App — Tracking screen logic
// Requirements: 5.1, 5.2

export type LocationCallback = (lat: number, lng: number) => void;

/** Active stub connections keyed by jobId */
const activeConnections: Map<string, ReturnType<typeof setInterval>> = new Map();

/**
 * Connect to job tracking for the given jobId.
 * In a real app this would open a WebSocket to /track/job/:jobId.
 * This stub calls onLocation with mock data at 5-second intervals.
 * Requirement 5.1: broadcast Worker location at ≤10s intervals.
 * Requirement 5.2: Customer App updates map position within 10s.
 */
export function connectToJobTracking(
  jobId: string,
  onLocation: LocationCallback
): void {
  if (activeConnections.has(jobId)) {
    return; // already connected
  }

  // Emit an initial mock location immediately
  onLocation(12.9716, 77.5946);

  // Then emit updates every 5 seconds (stub)
  const interval = setInterval(() => {
    // Slightly vary the mock coordinates to simulate movement
    const lat = 12.9716 + (Math.random() - 0.5) * 0.01;
    const lng = 77.5946 + (Math.random() - 0.5) * 0.01;
    onLocation(lat, lng);
  }, 5000);

  activeConnections.set(jobId, interval);
}

/**
 * Disconnect from job tracking for the given jobId.
 * Requirement 5.5: stop broadcasting on job completion.
 */
export function disconnectFromJobTracking(jobId: string): void {
  const interval = activeConnections.get(jobId);
  if (interval !== undefined) {
    clearInterval(interval);
    activeConnections.delete(jobId);
  }
}

/** Returns true if there is an active tracking connection for the given jobId. */
export function isTrackingActive(jobId: string): boolean {
  return activeConnections.has(jobId);
}
