-- Auth Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       VARCHAR(20) NOT NULL UNIQUE,
  name        VARCHAR(255) NOT NULL DEFAULT '',
  role        VARCHAR(20) NOT NULL CHECK (role IN ('customer', 'worker', 'admin')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE otp_records (
  phone        VARCHAR(20) PRIMARY KEY,
  otp_hash     TEXT NOT NULL,
  expires_at   TIMESTAMPTZ NOT NULL,
  attempts     INT NOT NULL DEFAULT 0,
  locked_until TIMESTAMPTZ
);

CREATE INDEX idx_otp_records_phone ON otp_records (phone);
