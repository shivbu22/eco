-- Worker Management Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE zones (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name             VARCHAR(255) NOT NULL,
  center_lat       DOUBLE PRECISION NOT NULL,
  center_lng       DOUBLE PRECISION NOT NULL,
  radius_meters    INT NOT NULL,
  adjacent_zone_ids UUID[] NOT NULL DEFAULT '{}'
);

CREATE TABLE workers (
  id           UUID PRIMARY KEY,  -- references users.id in auth-service
  zone_id      UUID NOT NULL REFERENCES zones(id),
  skills       TEXT[] NOT NULL DEFAULT '{}',
  availability BOOLEAN NOT NULL DEFAULT FALSE,
  kyc_status   VARCHAR(20) NOT NULL DEFAULT 'pending'
                 CHECK (kyc_status IN ('pending','verified','rejected')),
  rating       NUMERIC(3,2) NOT NULL DEFAULT 0.0,
  total_jobs   INT NOT NULL DEFAULT 0
);

CREATE TABLE kyc_submissions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id        UUID NOT NULL REFERENCES workers(id),
  id_document_url  TEXT NOT NULL,
  selfie_url       TEXT NOT NULL,
  status           VARCHAR(20) NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','approved','rejected')),
  reviewed_by      UUID,
  rejection_reason TEXT,
  submitted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at      TIMESTAMPTZ
);

CREATE INDEX idx_workers_zone_id    ON workers (zone_id);
CREATE INDEX idx_workers_kyc_status ON workers (kyc_status);
CREATE INDEX idx_workers_availability ON workers (availability);
