-- Booking Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE jobs (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id      UUID NOT NULL,
  worker_id        UUID,
  service_type     VARCHAR(100) NOT NULL,
  status           VARCHAR(20) NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','assigned','en_route','in_progress','completed','cancelled')),
  location_lat     DOUBLE PRECISION NOT NULL,
  location_lng     DOUBLE PRECISION NOT NULL,
  location_address TEXT NOT NULL,
  zone_id          UUID NOT NULL,
  scheduled_time   TIMESTAMPTZ,
  before_photo_url TEXT,
  after_photo_url  TEXT,
  price            NUMERIC(10,2) NOT NULL DEFAULT 0,
  cancel_reason    TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_jobs_customer_id ON jobs (customer_id);
CREATE INDEX idx_jobs_worker_id   ON jobs (worker_id);
CREATE INDEX idx_jobs_status      ON jobs (status);
CREATE INDEX idx_jobs_zone_id     ON jobs (zone_id);
CREATE INDEX idx_jobs_created_at  ON jobs (created_at);

CREATE TABLE b2b_contracts (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name          VARCHAR(255) NOT NULL,
  service_scope        TEXT NOT NULL,
  zone_id              UUID NOT NULL,
  monthly_rate         NUMERIC(10,2) NOT NULL,
  start_date           DATE NOT NULL,
  end_date             DATE NOT NULL,
  status               VARCHAR(20) NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('active','expired','pending')),
  recurrence_schedule  VARCHAR(100) NOT NULL
);
