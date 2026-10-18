-- Analytics Service — initial schema (read replica / materialized views)

-- This DB is populated from a read replica of the Jobs DB.
-- Materialized views are refreshed every 5 minutes.

CREATE TABLE analytics_jobs_snapshot (
  id           UUID PRIMARY KEY,
  customer_id  UUID NOT NULL,
  worker_id    UUID,
  service_type VARCHAR(100) NOT NULL,
  status       VARCHAR(20) NOT NULL,
  zone_id      UUID NOT NULL,
  price        NUMERIC(10,2) NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_analytics_created_at   ON analytics_jobs_snapshot (created_at);
CREATE INDEX idx_analytics_zone_id      ON analytics_jobs_snapshot (zone_id);
CREATE INDEX idx_analytics_service_type ON analytics_jobs_snapshot (service_type);
CREATE INDEX idx_analytics_status       ON analytics_jobs_snapshot (status);
