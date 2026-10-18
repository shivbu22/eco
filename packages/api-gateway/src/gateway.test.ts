import { describe, it, expect, beforeEach } from "vitest";
import * as jwt from "jsonwebtoken";
import { validateJwt, createRateLimiter, createErrorEnvelope } from "./gateway";

const SECRET = "test-secret";

// --- validateJwt ---

describe("validateJwt", () => {
  it("returns valid=true with payload for a valid token", () => {
    const token = jwt.sign({ userId: "user-1", role: "customer" }, SECRET, { expiresIn: "1h" });
    const result = validateJwt(token, SECRET);

    expect(result.valid).toBe(true);
    if (result.valid) {
      expect(result.payload.userId).toBe("user-1");
      expect(result.payload.role).toBe("customer");
    }
  });

  it("returns valid=false for an expired token", () => {
    const token = jwt.sign({ userId: "user-1", role: "customer" }, SECRET, { expiresIn: -1 });
    const result = validateJwt(token, SECRET);

    expect(result.valid).toBe(false);
    if (!result.valid) {
      expect(result.error).toBeTruthy();
    }
  });

  it("returns valid=false for a token signed with a different secret", () => {
    const token = jwt.sign({ userId: "user-1", role: "customer" }, "wrong-secret");
    const result = validateJwt(token, SECRET);

    expect(result.valid).toBe(false);
  });

  it("returns valid=false for a malformed token string", () => {
    const result = validateJwt("not.a.valid.token", SECRET);
    expect(result.valid).toBe(false);
  });

  it("returns valid=false when payload is missing userId", () => {
    const token = jwt.sign({ role: "admin" }, SECRET);
    const result = validateJwt(token, SECRET);
    expect(result.valid).toBe(false);
  });

  it("returns valid=false when payload is missing role", () => {
    const token = jwt.sign({ userId: "user-1" }, SECRET);
    const result = validateJwt(token, SECRET);
    expect(result.valid).toBe(false);
  });
});

// --- createRateLimiter ---

describe("createRateLimiter", () => {
  it("allows requests under the authenticated limit (100 req/min)", () => {
    const limiter = createRateLimiter(100, 60_000);
    for (let i = 0; i < 100; i++) {
      expect(limiter("user-1")).toBe(true);
    }
  });

  it("blocks the 101st request for an authenticated user", () => {
    const limiter = createRateLimiter(100, 60_000);
    for (let i = 0; i < 100; i++) {
      limiter("user-1");
    }
    expect(limiter("user-1")).toBe(false);
  });

  it("allows up to 10 requests for unauthenticated users", () => {
    const limiter = createRateLimiter(100, 60_000);
    for (let i = 0; i < 10; i++) {
      expect(limiter(null)).toBe(true);
    }
  });

  it("blocks the 11th request for unauthenticated users", () => {
    const limiter = createRateLimiter(100, 60_000);
    for (let i = 0; i < 10; i++) {
      limiter(null);
    }
    expect(limiter(null)).toBe(false);
  });

  it("tracks different users independently", () => {
    const limiter = createRateLimiter(2, 60_000);
    expect(limiter("user-a")).toBe(true);
    expect(limiter("user-a")).toBe(true);
    expect(limiter("user-a")).toBe(false); // user-a exhausted

    expect(limiter("user-b")).toBe(true); // user-b unaffected
  });

  it("resets the window after windowMs elapses", async () => {
    const limiter = createRateLimiter(1, 50); // 50ms window
    expect(limiter("user-1")).toBe(true);
    expect(limiter("user-1")).toBe(false); // exhausted

    await new Promise((r) => setTimeout(r, 60)); // wait for window to expire

    expect(limiter("user-1")).toBe(true); // new window
  });
});

// --- createErrorEnvelope ---

describe("createErrorEnvelope", () => {
  it("returns the correct structure with code and message", () => {
    const envelope = createErrorEnvelope("NOT_FOUND", "Resource not found");
    expect(envelope).toEqual({
      error: {
        code: "NOT_FOUND",
        message: "Resource not found",
      },
    });
  });

  it("includes details when provided", () => {
    const details = { field: "email", reason: "invalid format" };
    const envelope = createErrorEnvelope("VALIDATION_ERROR", "Invalid input", details);
    expect(envelope.error.code).toBe("VALIDATION_ERROR");
    expect(envelope.error.message).toBe("Invalid input");
    expect(envelope.error.details).toEqual(details);
  });

  it("omits details key when not provided", () => {
    const envelope = createErrorEnvelope("SERVER_ERROR", "Internal error");
    expect("details" in envelope.error).toBe(false);
  });
});
