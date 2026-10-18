-- Recycling Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE recycling_buy_rates (
  waste_category  VARCHAR(50) PRIMARY KEY
                    CHECK (waste_category IN ('scrap_metal','paper','plastic','e_waste')),
  rate_per_kg     NUMERIC(10,4) NOT NULL,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE recycling_records (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id            UUID NOT NULL UNIQUE,
  customer_id       UUID NOT NULL,
  waste_category    VARCHAR(50) NOT NULL
                      CHECK (waste_category IN ('scrap_metal','paper','plastic','e_waste')),
  weight_kg         NUMERIC(10,3) NOT NULL,
  payout_amount     NUMERIC(10,2) NOT NULL,
  payout_preference VARCHAR(20) NOT NULL CHECK (payout_preference IN ('cash','eco_points')),
  payout_status     VARCHAR(20) NOT NULL DEFAULT 'pending'
                      CHECK (payout_status IN ('pending','processed')),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recycling_customer ON recycling_records (customer_id);
