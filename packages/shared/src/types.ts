// Ecomins Platform — Shared TypeScript Interfaces

export interface User {
  id: string; // UUID
  phone: string; // E.164 format
  name: string;
  role: "customer" | "worker" | "admin";
  created_at: string; // ISO 8601
}

export interface Worker {
  id: string; // UUID, references User.id
  zone_id: string;
  skills: string[]; // e.g. ["cleaning", "recycling"]
  availability: boolean;
  kyc_status: "pending" | "verified" | "rejected";
  rating: number; // 0.0 – 5.0
  total_jobs: number;
}

export interface Zone {
  id: string;
  name: string;
  center_lat: number;
  center_lng: number;
  radius_meters: number;
  adjacent_zone_ids: string[];
}

export interface JobLocation {
  lat: number;
  lng: number;
  address: string;
}

export interface Job {
  id: string;
  customer_id: string;
  worker_id: string | null;
  service_type: string;
  status: "pending" | "assigned" | "en_route" | "in_progress" | "completed" | "cancelled";
  location: JobLocation;
  zone_id: string;
  scheduled_time: string | null;
  before_photo_url: string | null;
  after_photo_url: string | null;
  price: number;
  created_at: string;
  updated_at: string;
}

export interface KYCSubmission {
  id: string;
  worker_id: string;
  id_document_url: string;
  selfie_url: string;
  status: "pending" | "approved" | "rejected";
  reviewed_by: string | null;
  rejection_reason: string | null;
  submitted_at: string;
  reviewed_at: string | null;
}

export interface EarningsRecord {
  id: string;
  worker_id: string;
  job_id: string;
  gross_amount: number;
  commission_rate: number;
  net_amount: number;
  created_at: string;
}

export interface PricingRule {
  id: string;
  service_type: string;
  zone_id: string;
  base_rate: number;
  tax_rate: number; // percentage, e.g. 0.18 for 18%
  surcharge: number;
  effective_from: string; // ISO 8601
}

export interface RewardsAccount {
  customer_id: string;
  points_balance: number;
  eco_score: number;
}

export interface RecyclingRecord {
  id: string;
  job_id: string;
  customer_id: string;
  waste_category: "scrap_metal" | "paper" | "plastic" | "e_waste";
  weight_kg: number;
  payout_amount: number;
  payout_preference: "cash" | "eco_points";
  payout_status: "pending" | "processed";
  created_at: string;
}

export interface B2BContract {
  id: string;
  client_name: string;
  service_scope: string;
  zone_id: string;
  monthly_rate: number;
  start_date: string;
  end_date: string;
  status: "active" | "expired" | "pending";
  recurrence_schedule: string; // cron expression
}

export interface OTPRecord {
  phone: string;
  otp_hash: string; // bcrypt hash of OTP
  expires_at: string; // ISO 8601, 5 minutes from creation
  attempts: number;
  locked_until: string | null;
}

// Error envelope used by all services
export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}
