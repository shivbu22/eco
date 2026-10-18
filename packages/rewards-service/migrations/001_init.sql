-- Rewards Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE rewards_accounts (
  customer_id     UUID PRIMARY KEY,
  points_balance  INT NOT NULL DEFAULT 0,
  eco_score       INT NOT NULL DEFAULT 0
);

CREATE TABLE rewards_transactions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id  UUID NOT NULL REFERENCES rewards_accounts(customer_id),
  type         VARCHAR(20) NOT NULL CHECK (type IN ('award', 'redeem')),
  points       INT NOT NULL,
  job_id       UUID,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rewards_transactions_customer ON rewards_transactions (customer_id);
