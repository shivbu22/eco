-- Notification Service — initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE notification_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL,
  title        VARCHAR(255) NOT NULL,
  body         TEXT NOT NULL,
  status       VARCHAR(20) NOT NULL CHECK (status IN ('sent','failed','retrying')),
  attempts     INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_attempt TIMESTAMPTZ
);

CREATE INDEX idx_notification_log_user_id ON notification_log (user_id);
CREATE INDEX idx_notification_log_status  ON notification_log (status);
