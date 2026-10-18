-- Tracking Service — initial schema
-- Stores last known worker locations for buffering on WebSocket reconnect.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE worker_locations (
  worker_id   UUID PRIMARY KEY,
  job_id      UUID NOT NULL,
  lat         DOUBLE PRECISION NOT NULL,
  lng         DOUBLE PRECISION NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_worker_locations_job_id ON worker_locations (job_id);
