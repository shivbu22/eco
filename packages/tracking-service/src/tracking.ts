// Tracking Service — pure logic layer
// Manages worker location state and subscriber callbacks per job.
// No real WebSocket or Redis dependency — callers wire those in.

export interface Location {
  workerId: string;
  jobId: string;
  lat: number;
  lng: number;
  updatedAt: number; // epoch ms
}

export type LocationCallback = (location: Location) => void;

// In-memory stores
const locations = new Map<string, Location>();
const subscribers = new Map<string, LocationCallback[]>();

/**
 * Store the latest location for a worker+job pair and notify subscribers.
 * Requirements: 5.1, 5.2
 */
export function updateLocation(
  workerId: string,
  jobId: string,
  lat: number,
  lng: number
): void {
  const location: Location = { workerId, jobId, lat, lng, updatedAt: Date.now() };
  locations.set(jobId, location);

  const cbs = subscribers.get(jobId);
  if (cbs) {
    for (const cb of cbs) {
      cb(location);
    }
  }
}

/**
 * Return the last known location for a job, or null if unknown.
 * Requirements: 5.4
 */
export function getLastLocation(jobId: string): Location | null {
  return locations.get(jobId) ?? null;
}

/**
 * Register a callback that fires whenever the location for jobId updates.
 * Requirements: 5.1
 */
export function subscribeToJob(jobId: string, callback: LocationCallback): void {
  const existing = subscribers.get(jobId) ?? [];
  subscribers.set(jobId, [...existing, callback]);
}

/**
 * Remove all subscribers for a job (called on job completion).
 * Requirements: 5.5
 */
export function unsubscribeFromJob(jobId: string): void {
  subscribers.delete(jobId);
}

/**
 * Stop broadcasting for a job — clears both location and subscribers.
 * Requirements: 5.5
 */
export function stopTracking(jobId: string): void {
  locations.delete(jobId);
  subscribers.delete(jobId);
}
