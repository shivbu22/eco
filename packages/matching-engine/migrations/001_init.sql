-- Matching Engine — initial schema
-- The matching engine is primarily event-driven and stateless.
-- It reads from the workers DB and writes job assignments back to the booking service.
-- This migration sets up any local state needed for match tracking.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE match_attempts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id          UUID NOT NULL,
  worker_id       UUID NOT NULL,
  attempted_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  outcome         VARCHAR(20) NOT NULL CHECK (outcome IN ('assigned','rejected','timeout'))
);

CREATE INDEX idx_match_attempts_job_id ON match_attempts (job_id);
