// Matching Engine — core matching logic
// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 7.6

import type { Worker, Job, Zone } from "@ecomins/shared";

/** Worker extended with geographic coordinates for matching purposes */
export interface WorkerWithLocation extends Worker {
  lat: number;
  lng: number;
}

/**
 * Filter workers to those eligible for a job:
 * - kyc_status === "verified"
 * - availability === true
 * - skills includes job.service_type
 *
 * Validates: Requirements 4.1, 7.6
 */
export function filterEligibleWorkers(
  workers: WorkerWithLocation[],
  job: Job
): WorkerWithLocation[] {
  return workers.filter(
    (w) =>
      w.kyc_status === "verified" &&
      w.availability === true &&
      w.skills.includes(job.service_type)
  );
}

/**
 * Compute the great-circle distance in kilometres between two coordinates
 * using the Haversine formula.
 *
 * Validates: Requirements 4.2
 */
export function haversineDistance(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number {
  const R = 6371; // Earth radius in km
  const toRad = (deg: number) => (deg * Math.PI) / 180;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * From a list of eligible workers, return the one closest to the given
 * job coordinates, or null if the list is empty.
 *
 * Validates: Requirements 4.2
 */
export function findNearestWorker(
  eligibleWorkers: WorkerWithLocation[],
  jobLat: number,
  jobLng: number
): WorkerWithLocation | null {
  if (eligibleWorkers.length === 0) return null;

  return eligibleWorkers.reduce((nearest, worker) => {
    const dNearest = haversineDistance(nearest.lat, nearest.lng, jobLat, jobLng);
    const dWorker = haversineDistance(worker.lat, worker.lng, jobLat, jobLng);
    return dWorker < dNearest ? worker : nearest;
  });
}

/**
 * Full matching pipeline:
 * 1. Filter eligible workers in the job's zone.
 * 2. If found, return the nearest one.
 * 3. If none in primary zone, check adjacent zones (from Zone.adjacent_zone_ids).
 * 4. Return the assigned worker or null if no match found.
 *
 * Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 7.6
 */
export function matchJob(
  job: Job,
  workers: WorkerWithLocation[],
  zones: Zone[]
): WorkerWithLocation | null {
  const eligible = filterEligibleWorkers(workers, job);

  // Primary zone search
  const inPrimaryZone = eligible.filter((w) => w.zone_id === job.zone_id);
  const nearest = findNearestWorker(inPrimaryZone, job.location.lat, job.location.lng);
  if (nearest) return nearest;

  // Adjacent zone fallback (Requirement 4.4)
  const primaryZone = zones.find((z) => z.id === job.zone_id);
  if (!primaryZone || primaryZone.adjacent_zone_ids.length === 0) return null;

  const inAdjacentZones = eligible.filter((w) =>
    primaryZone.adjacent_zone_ids.includes(w.zone_id)
  );
  return findNearestWorker(inAdjacentZones, job.location.lat, job.location.lng);
}
