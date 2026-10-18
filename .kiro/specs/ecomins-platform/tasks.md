# Implementation Plan: Ecomins Platform

## Overview

This plan breaks the Ecomins platform into incremental coding tasks. Each task builds on the previous, starting with shared infrastructure and data models, then implementing each service, then wiring the client apps. Property-based tests are placed close to the implementation they validate.

The stack assumed: Node.js + TypeScript (backend services), React Native (mobile apps), React + TypeScript (Admin Panel), PostgreSQL (primary DB), Redis (caching/pub-sub), S3-compatible storage (images), FCM (push notifications), `fast-check` (property-based testing).

---

## Tasks

- [x] 1. Project scaffolding and shared infrastructure
  - Initialize monorepo structure with packages: `api-gateway`, `auth-service`, `booking-service`, `matching-engine`, `worker-service`, `tracking-service`, `notification-service`, `earnings-service`, `pricing-service`, `rewards-service`, `recycling-service`, `analytics-service`, `shared`, `customer-app`, `worker-app`, `admin-panel`
  - Set up TypeScript config, ESLint, Prettier across all packages
  - Define shared TypeScript interfaces for all data models (User, Worker, Zone, Job, KYCSubmission, EarningsRecord, PricingRule, RewardsAccount, RecyclingRecord, B2BContract, OTPRecord) in `shared/types.ts`
  - Set up PostgreSQL schema migrations (one migration file per service DB)
  - Configure `fast-check` as the property-based testing library in all backend packages
  - _Requirements: All_

- [x] 2. Auth Service
  - [x] 2.1 Implement OTP generation, hashing (bcrypt), and SMS dispatch
    - `POST /auth/request-otp` — generate 6-digit OTP, hash and store in OTPRecord, dispatch via SMS provider
    - `POST /auth/verify-otp` — validate OTP hash, check expiry (5 min), check lockout, issue JWT on success
    - Implement lockout logic: increment `attempts` on failure, set `locked_until` after 3 failures
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 2.2 Write property test: OTP lockout after 3 failures
    - **Property 1: OTP lockout after repeated failures**
    - **Validates: Requirements 1.3**
    - Generate random phone numbers, simulate 3+ consecutive incorrect OTP submissions, assert all subsequent attempts are rejected with 429 until lockout expires
    - Tag: `// Feature: ecomins-platform, Property 1: OTP lockout after repeated failures`

  - [x] 2.3 Write property test: OTP expiry invalidation
    - **Property 2: OTP expiry invalidation**
    - **Validates: Requirements 1.4**
    - Generate random OTPs with `expires_at` set to a past timestamp, assert that submitting the correct OTP value still returns 401
    - Tag: `// Feature: ecomins-platform, Property 2: OTP expiry invalidation`

- [x] 3. Checkpoint — Auth Service
  - Ensure all Auth Service tests pass, ask the user if questions arise.

- [x] 4. Pricing Service
  - [x] 4.1 Implement pricing rule storage and price calculation
    - `POST /pricing` — store PricingRule with `effective_from` timestamp
    - `PATCH /pricing/:id` — update rule, set new `effective_from` to current time
    - `GET /pricing/:service_type/:zone_id` — return the active rule (latest `effective_from` ≤ now) and compute `total = base_rate * (1 + tax_rate) + surcharge`
    - _Requirements: 13.1, 13.2, 13.3_

  - [x] 4.2 Write property test: Pricing rule temporal isolation
    - **Property 8: Pricing rule temporal isolation**
    - **Validates: Requirements 13.3**
    - For any pricing rule update, generate jobs with `created_at` before and after the update timestamp, assert jobs before retain old price and jobs after use new price
    - Tag: `// Feature: ecomins-platform, Property 8: Pricing rule temporal isolation`

  - [x] 4.3 Write property test: Booking price consistency
    - **Property 3: Booking price consistency**
    - **Validates: Requirements 3.5, 13.2**
    - For any service type and zone, assert that the price returned by `GET /pricing/:service_type/:zone_id` equals the price stored on the Job record created for that service/zone combination
    - Tag: `// Feature: ecomins-platform, Property 3: Booking price consistency`

- [x] 5. Worker Management Service
  - [x] 5.1 Implement Worker CRUD, KYC workflow, and availability toggle
    - `POST /workers` — create Worker record, validate required fields (name, phone, zone_id, skills)
    - `GET /workers/:id` — return Worker profile
    - `PATCH /workers/:id/availability` — update `availability` field immediately
    - `POST /workers/:id/kyc` — create KYCSubmission record with status "pending"
    - `PATCH /workers/:id/kyc/review` — Admin approves/rejects: update `kyc_status` on Worker and KYCSubmission, store rejection reason
    - `PATCH /workers/:id/zone` — update Worker zone assignment
    - _Requirements: 7.1, 7.2, 7.4, 7.5, 8.5, 8.6, 11.2, 11.4_

  - [x] 5.2 Write property test: KYC state transition validity
    - **Property (from 7.4, 7.5): KYC approval/rejection state transitions**
    - **Validates: Requirements 7.4, 7.5**
    - For any KYC submission, assert that after approval `kyc_status` is "verified", and after rejection `kyc_status` is "rejected" with a non-empty reason
    - Tag: `// Feature: ecomins-platform, Property: KYC state transition validity`

  - [x] 5.3 Write property test: Availability toggle immediate effect
    - **Property 11: Availability toggle immediate effect**
    - **Validates: Requirements 8.5, 8.6**
    - For any Worker, toggling availability to false then true should restore the original available state (round-trip). After toggling to false, the worker should not appear in any eligible pool query.
    - Tag: `// Feature: ecomins-platform, Property 11: Availability toggle immediate effect`

- [x] 6. Booking Service — core job lifecycle
  - [x] 6.1 Implement Job creation and booking flow validation
    - `POST /jobs` — validate required fields, call Pricing Service for price, create Job with status "pending", return job_id
    - Validate photo uploads: accept only JPEG/PNG ≤ 10MB, return 400 with descriptive error otherwise
    - Validate Customer profile completeness (name + address) before allowing first booking
    - _Requirements: 3.2, 3.3, 3.5, 3.6, 1.6_

  - [x] 6.2 Write property test: Image format and size validation
    - **Property (from 3.2, 3.3, 6.3): Image upload validation**
    - **Validates: Requirements 3.2, 3.3, 6.3**
    - For any file with invalid MIME type or size > 10MB, assert the upload is rejected with a 400 error. For any valid JPEG/PNG ≤ 10MB, assert acceptance.
    - Tag: `// Feature: ecomins-platform, Property: Image format and size validation`

  - [x] 6.3 Write property test: New jobs always start as "pending"
    - **Property (from 3.6): Job creation status invariant**
    - **Validates: Requirements 3.6**
    - For any valid booking input, assert the created Job record has status "pending"
    - Tag: `// Feature: ecomins-platform, Property: New jobs always start as pending`

  - [x] 6.4 Implement Job status transitions and proof submission
    - `POST /jobs/:id/start` — require `before_photo_url`, transition pending/assigned/en_route → in_progress
    - `POST /jobs/:id/complete` — require `after_photo_url`, transition in_progress → completed, trigger earnings calculation event
    - `POST /jobs/:id/cancel` — require `reason`, transition any state → cancelled
    - Enforce valid state machine: reject invalid transitions with 409
    - _Requirements: 6.1, 6.2, 6.4, 6.5, 6.6, 5.5_

  - [x] 6.5 Write property test: Proof required for status transitions
    - **Property 6: Proof required before status transition**
    - **Validates: Requirements 6.1, 6.2, 6.4**
    - For any Job, assert that calling `/start` without `before_photo_url` returns an error, and calling `/complete` without `after_photo_url` returns an error
    - Tag: `// Feature: ecomins-platform, Property 6: Proof required before status transition`

  - [x] 6.6 Write property test: Job status transition validity
    - **Property 12: Job status transition validity**
    - **Validates: Requirements 4.3, 8.3, 5.5**
    - For any Job, assert that only valid transitions (pending→assigned, assigned→en_route, en_route→in_progress, in_progress→completed, any→cancelled) are accepted, and all other transitions return 409
    - Tag: `// Feature: ecomins-platform, Property 12: Job status transition validity`

- [x] 7. Checkpoint — Booking and Pricing
  - Ensure all Booking Service and Pricing Service tests pass, ask the user if questions arise.

- [x] 8. Matching Engine
  - [x] 8.1 Implement worker eligibility filtering and nearest-worker selection
    - On `job.created` event: query Workers in same Zone with matching skill, `kyc_status = "verified"`, `availability = true`
    - Sort eligible workers by Haversine distance from Job location, assign nearest
    - On no match within 2 minutes: expand query to adjacent zones (from `Zone.adjacent_zone_ids`)
    - On no match after expansion: set Job status to "unassigned", emit notification event
    - On `job.rejected` event: re-run matching excluding the rejecting Worker
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 7.6_

  - [x] 8.2 Write property test: Matching only assigns eligible workers
    - **Property 4: Matching only assigns verified, available workers**
    - **Validates: Requirements 4.1, 7.6**
    - For any job and any pool of workers with mixed kyc_status and availability values, assert the assigned worker always has `kyc_status = "verified"` and `availability = true` and possesses the required skill
    - Tag: `// Feature: ecomins-platform, Property 4: Matching only assigns eligible workers`

  - [x] 8.3 Write property test: Nearest worker is assigned first
    - **Property 5: Nearest worker assigned first**
    - **Validates: Requirements 4.2**
    - For any set of eligible workers at random locations, assert the worker with the minimum Haversine distance to the job location is always the one assigned
    - Tag: `// Feature: ecomins-platform, Property 5: Nearest worker assigned first`

- [x] 9. Earnings Service
  - [x] 9.1 Implement earnings calculation and record storage
    - On `job.completed` event: fetch Job price and commission rate, compute `net_amount = price * (1 - commission_rate)`, create EarningsRecord
    - `GET /earnings/:worker_id` — aggregate today/week/all-time totals from EarningsRecord
    - `GET /earnings/:worker_id/jobs` — return list of EarningsRecords
    - _Requirements: 9.1, 9.2, 9.5_

  - [x] 9.2 Write property test: Earnings net amount invariant
    - **Property 7: Earnings net amount invariant**
    - **Validates: Requirements 9.1, 9.5**
    - For any job price and commission rate in [0, 1), assert `net_amount = price * (1 - commission_rate)` and `net_amount >= 0`
    - Tag: `// Feature: ecomins-platform, Property 7: Earnings net amount invariant`

- [x] 10. Notification Service
  - [x] 10.1 Implement push notification dispatch with retry logic
    - `POST /notify` — send push via FCM, on failure retry up to 3 times with exponential backoff (1s, 2s, 4s), log all attempts and outcomes
    - Subscribe to job status change events and dispatch appropriate notifications per Requirements 14.1–14.4
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

  - [x] 10.2 Write property test: Notification retry behavior
    - **Property (from 14.5): Notification retry up to 3 times**
    - **Validates: Requirements 14.5**
    - For any notification that fails delivery, assert the service retries exactly up to 3 times and logs a failure after all retries are exhausted
    - Tag: `// Feature: ecomins-platform, Property: Notification retry behavior`

  - [x] 10.3 Write property test: Every job status change triggers a notification
    - **Property (from 5.3): Status change notification invariant**
    - **Validates: Requirements 5.3, 14.1, 14.2, 14.3, 14.4**
    - For any valid job status transition, assert that a notification event is emitted to the relevant parties (Customer and/or Worker)
    - Tag: `// Feature: ecomins-platform, Property: Status change notification invariant`

- [x] 11. Tracking Service
  - [x] 11.1 Implement WebSocket location broadcasting
    - `POST /track/location` — accept Worker location update, publish to Redis pub/sub channel keyed by job_id
    - `WebSocket /track/job/:job_id` — Customer subscribes, receives location updates from Redis channel
    - On Job completion: unsubscribe all listeners for that job_id, stop broadcasting
    - _Requirements: 5.1, 5.2, 5.5_

- [x] 12. Rewards Service
  - [x] 12.1 Implement Eco Points award, redemption, and balance management
    - `POST /rewards/:customer_id/award` — add points to balance, update eco_score, emit notification
    - `POST /rewards/:customer_id/redeem` — validate balance ≥ requested points, deduct and apply discount; reject with 400 if insufficient
    - `GET /rewards/:customer_id` — return current balance and eco_score
    - On eco-service job completion event: auto-award points per service type config
    - _Requirements: 15.1, 15.2, 15.4, 15.5_

  - [x] 12.2 Write property test: Eco Points balance non-negative invariant
    - **Property 9: Eco Points balance non-negative invariant**
    - **Validates: Requirements 15.4, 15.5**
    - For any sequence of award and redemption operations on a random starting balance, assert the balance never goes negative
    - Tag: `// Feature: ecomins-platform, Property 9: Eco Points balance non-negative invariant`

- [x] 13. Recycling Service
  - [x] 13.1 Implement recycling record creation and payout calculation
    - `POST /recycling/:job_id/record` — store RecyclingRecord with waste_category, weight_kg, payout_preference
    - Calculate `payout_amount = weight_kg * buy_rate[waste_category]`
    - If `payout_preference = "eco_points"`: call Rewards Service to award equivalent points
    - If `payout_preference = "cash"`: create a pending cash transfer record, initiate transfer within 24h
    - `GET /recycling/:job_id` — return RecyclingRecord
    - _Requirements: 18.3, 18.4, 18.5_

  - [x] 13.2 Write property test: Recycling payout calculation consistency
    - **Property 10: Recycling payout calculation consistency**
    - **Validates: Requirements 18.4**
    - For any waste category and weight, assert `payout_amount = weight_kg * buy_rate[waste_category]`
    - Tag: `// Feature: ecomins-platform, Property 10: Recycling payout calculation consistency`

- [x] 14. Analytics Service
  - [x] 14.1 Implement analytics aggregation and CSV export
    - `GET /analytics/summary` — aggregate total jobs, revenue, waste processed, active workers for given filters (date range, zone_id, service_type) from read replica
    - `GET /analytics/export` — stream CSV of filtered Job records
    - Implement filter validation: all returned records must match all provided filter criteria
    - _Requirements: 12.1, 12.2, 12.3_

  - [x] 14.2 Write property test: Analytics filter correctness
    - **Property 14: Analytics filter correctness**
    - **Validates: Requirements 12.2**
    - For any analytics query with a date range filter, assert all returned Job records have `created_at` within the specified range and no out-of-range records appear
    - Tag: `// Feature: ecomins-platform, Property 14: Analytics filter correctness`

- [x] 15. Checkpoint — Core Services
  - Ensure all service tests pass (Auth, Pricing, Booking, Matching, Earnings, Notifications, Tracking, Rewards, Recycling, Analytics), ask the user if questions arise.

- [x] 16. B2B Contract job generation
  - [x] 16.1 Implement B2B contract CRUD and scheduled job generation
    - `POST /contracts` — create B2BContract, validate all required fields (client_name, service_scope, zone_id, start_date, end_date, monthly_rate, recurrence_schedule)
    - Implement a scheduler (cron) that reads active contracts and generates Jobs per `recurrence_schedule`
    - On contract expiry: stop job generation, emit Admin notification
    - `GET /contracts` — return all contracts with status
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [x] 16.2 Write property test: B2B contract validation
    - **Property (from 17.1): B2B contract requires all mandatory fields**
    - **Validates: Requirements 17.1**
    - For any contract creation request missing any mandatory field, assert the request is rejected with a 400 error
    - Tag: `// Feature: ecomins-platform, Property: B2B contract validation`

- [x] 17. Offline sync (Worker App service layer)
  - [x] 17.1 Implement local job state persistence and sync logic
    - In Worker App: persist active Job state and queued status updates to local storage (AsyncStorage or SQLite)
    - On connectivity restore: replay queued updates to server in order, using idempotency keys to prevent duplicate application
    - On sync failure: retry up to 5 times with exponential backoff, alert Worker if all retries fail
    - _Requirements: 16.1, 16.2, 16.3_

  - [x] 17.2 Write property test: Offline sync idempotency
    - **Property 13: Offline sync idempotency**
    - **Validates: Requirements 16.2, 16.3**
    - For any set of locally buffered status updates, assert that syncing them once and syncing them multiple times produces the same final server state
    - Tag: `// Feature: ecomins-platform, Property 13: Offline sync idempotency`

- [x] 18. API Gateway wiring
  - Configure routing rules for all services
  - Implement JWT validation middleware (verify token, extract user_id and role, attach to request context)
  - Implement rate limiting (100 req/min authenticated, 10 req/min unauthenticated)
  - Implement consistent error envelope middleware
  - _Requirements: All API-facing requirements_

- [x] 19. Customer App — core screens
  - [x] 19.1 Implement authentication screens (OTP request + verification)
    - Phone input screen → call `POST /auth/request-otp`
    - OTP entry screen → call `POST /auth/verify-otp`, store JWT, navigate to home
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 19.2 Implement home screen and service browsing
    - Render service category grid (Cleaning, Waste Management, Logistics, B2B, Recycling)
    - On category tap: fetch and display sub-services with name, description, base price
    - Display availability based on Customer's zone
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 19.3 Implement booking flow
    - Sequential screens: service selection → photo upload (optional) → location confirmation → price display → confirm
    - Validate photo format/size client-side before upload
    - Call `POST /jobs` on confirmation, navigate to tracking screen with returned job_id
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x] 19.4 Implement live tracking screen
    - Subscribe to `WebSocket /track/job/:job_id`
    - Render map with Worker marker, update position on each location event
    - Display job status banner, update on status change notifications
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [x] 19.5 Implement orders history and rewards screens
    - Orders: list active and past Jobs with status, proof images, and price
    - Rewards: display Eco Points balance, Eco Score, redemption UI
    - _Requirements: 15.3, 9.3_

- [x] 20. Worker App — core screens
  - [x] 20.1 Implement Worker authentication and KYC submission screens
    - OTP login flow (same as Customer App auth)
    - KYC screen: upload government ID and selfie, call `POST /workers/:id/kyc`
    - _Requirements: 7.1, 7.2_

  - [x] 20.2 Implement job feed, accept/reject, and navigation screens
    - Job feed: list available Jobs in Worker's zone matching skills
    - Job detail: accept (call `POST /jobs/:id` accept) or reject
    - Navigation screen: display job location on map, Worker's current location
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [x] 20.3 Implement proof upload and job completion screens
    - Before photo capture/upload on job start
    - After photo capture/upload on job completion
    - Call `POST /jobs/:id/start` and `POST /jobs/:id/complete` with respective photo URLs
    - _Requirements: 6.1, 6.2, 6.4, 6.5_

  - [x] 20.4 Implement availability toggle, earnings dashboard, and offline indicator
    - Availability toggle: call `PATCH /workers/:id/availability`
    - Earnings dashboard: display today/week/all-time totals from `GET /earnings/:worker_id`
    - Offline indicator: show connectivity status banner when offline
    - _Requirements: 8.5, 8.6, 9.3, 9.4, 16.4_

- [x] 21. Admin Panel — core screens
  - [x] 21.1 Implement job management dashboard
    - Job list with status filters, search, and detail view
    - Manual job creation form (service type, location, scheduled time)
    - Manual worker assignment with eligibility validation
    - Job status update with mandatory reason field
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [x] 21.2 Implement worker management dashboard
    - Worker list with verification status, zone, skills, rating
    - KYC review screen: side-by-side ID document and selfie display, approve/reject with reason
    - Worker profile: job completion rate, average rating, total earnings, jobs completed
    - Zone assignment control
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 21.3 Implement analytics dashboard and pricing management
    - Analytics: summary metrics with date range / zone / service type filters, CSV export button
    - Pricing: table of current rates per service type and zone, inline editing
    - B2B contracts: list all contracts, create contract form
    - _Requirements: 12.1, 12.2, 12.3, 13.1, 13.4, 17.1, 17.4_

- [x] 22. Final checkpoint — Full integration
  - Ensure all unit, property, and integration tests pass across all packages.
  - Verify end-to-end flows: booking → matching → tracking → completion → earnings → notification.
  - Ask the user if questions arise.

---

## Notes

- All tasks are required, including property-based and unit tests
- Each task references specific requirements for traceability
- Property tests use `fast-check` with minimum 100 iterations each
- Each property test comment must include: `// Feature: ecomins-platform, Property N: <text>`
- Checkpoints ensure incremental validation before proceeding to the next layer
