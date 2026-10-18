// Notification Service — push dispatch with retry/backoff logic
// Requirements: 14.1, 14.2, 14.3, 14.4, 14.5

export interface NotificationResult {
  success: boolean;
  attempts: number;
  failureReason?: string;
}

export interface NotificationLogEntry {
  userId: string;
  title: string;
  body: string;
  attempt: number;
  success: boolean;
  error?: string;
  timestamp: string;
}

// In-memory log of all notification attempts
const notificationLog: NotificationLogEntry[] = [];

/** Default stub FCM dispatcher — always succeeds */
async function defaultDispatcher(
  _userId: string,
  _title: string,
  _body: string,
  _data?: Record<string, unknown>
): Promise<void> {
  // Stub: in production this would call FCM API
}

const RETRY_DELAYS_MS = [1000, 2000, 4000];

/**
 * Send a push notification to a user via FCM.
 * Retries up to 3 times with exponential backoff (1s, 2s, 4s) on failure.
 * Logs every attempt and outcome.
 */
export async function sendNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, unknown>,
  dispatcher: (
    userId: string,
    title: string,
    body: string,
    data?: Record<string, unknown>
  ) => Promise<void> = defaultDispatcher
): Promise<NotificationResult> {
  let lastError: string | undefined;

  for (let attempt = 1; attempt <= 4; attempt++) {
    try {
      await dispatcher(userId, title, body, data);

      notificationLog.push({
        userId,
        title,
        body,
        attempt,
        success: true,
        timestamp: new Date().toISOString(),
      });

      return { success: true, attempts: attempt };
    } catch (err) {
      lastError = err instanceof Error ? err.message : String(err);

      notificationLog.push({
        userId,
        title,
        body,
        attempt,
        success: false,
        error: lastError,
        timestamp: new Date().toISOString(),
      });

      // If we've exhausted all retries (3 retries after initial attempt), stop
      if (attempt === 4) break;

      // Wait before retrying (exponential backoff: 1s, 2s, 4s)
      await sleep(RETRY_DELAYS_MS[attempt - 1]);
    }
  }

  return {
    success: false,
    attempts: 4,
    failureReason: lastError,
  };
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** Return all logged notification attempts */
export function getNotificationLog(): NotificationLogEntry[] {
  return [...notificationLog];
}

/** Test helper — clear the log */
export function _clearLog(): void {
  notificationLog.length = 0;
}
