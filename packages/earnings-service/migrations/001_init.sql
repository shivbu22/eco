-- Earnings Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE earnings_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id       UUID NOT NULL,
  job_id          UUID NOT NULL UNIQUE,
  gross_amount    NUMERIC(10,2) NOT NULL,
  commission_rate NUMERIC(5,4) NOT NULL,
  net_amount      NUMERIC(10,2) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_earnings_worker_id  ON earnings_records (worker_id);
CREATE INDEX idx_earnings_created_at ON earnings_records (created_at);
