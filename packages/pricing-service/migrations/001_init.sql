-- Pricing Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE pricing_rules (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_type   VARCHAR(100) NOT NULL,
  zone_id        UUID NOT NULL,
  base_rate      NUMERIC(10,2) NOT NULL,
  tax_rate       NUMERIC(5,4) NOT NULL,  -- e.g. 0.18 for 18%
  surcharge      NUMERIC(10,2) NOT NULL DEFAULT 0,
  effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pricing_service_zone ON pricing_rules (service_type, zone_id);
CREATE INDEX idx_pricing_effective_from ON pricing_rules (effective_from);
