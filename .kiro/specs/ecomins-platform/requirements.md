# Requirements Document

## Introduction

Ecomins is a hyperlocal, on-demand sanitation and waste management platform that connects customers with verified workers to deliver cleaning services, garbage collection, waste transport, and recycling/waste monetization. The platform operates across three primary interfaces: a Customer App, a Worker App, and an Admin Panel, all backed by a shared API and core services including a booking engine, matching engine, and notification system.

This document captures the full requirements for the MVP and subsequent phases of the Ecomins platform.

---

## Glossary

- **Customer**: A registered user who books sanitation or waste management services through the Customer App.
- **Worker**: A verified, trained service provider who accepts and fulfills jobs through the Worker App.
- **Admin**: A platform operator who manages jobs, workers, pricing, and analytics through the Admin Panel.
- **Job**: A unit of work created when a Customer books a service, assigned to a Worker, and tracked through completion.
- **Zone**: A hyperlocal geographic cluster (500m–2km radius) used to group Workers and route Jobs efficiently.
- **Matching_Engine**: The backend service that finds and assigns the most suitable available Worker to a Job based on location, skill, and availability.
- **Booking_Service**: The backend service responsible for creating, updating, and managing the lifecycle of Jobs.
- **Notification_Service**: The backend service responsible for sending real-time push notifications and status updates to Customers and Workers.
- **KYC**: Know Your Customer — the identity verification process applied to Workers before they can accept Jobs.
- **Eco_Score**: A Customer-facing metric that tracks environmentally positive actions such as recycling and eco-service usage.
- **Proof_Submission**: Before and after images uploaded by a Worker to verify job completion.
- **Availability_Toggle**: A Worker-controlled switch that marks the Worker as available or unavailable for new Jobs.
- **Subscription_Plan**: A recurring payment plan that gives Customers discounted or bundled access to services.
- **B2B_Contract**: A monthly service agreement between Ecomins and a business or residential society.

---

## Requirements

### Requirement 1: Customer Registration and Authentication

**User Story:** As a customer, I want to register and log in securely, so that I can access the platform and book services.

#### Acceptance Criteria

1. WHEN a new user provides a valid phone number, THE Authentication_Service SHALL send a one-time password (OTP) to that phone number within 30 seconds.
2. WHEN a user submits a correct OTP within 5 minutes of issuance, THE Authentication_Service SHALL create an authenticated session and return a session token.
3. IF a user submits an incorrect OTP 3 or more consecutive times, THEN THE Authentication_Service SHALL lock the OTP attempt for 15 minutes and return an error message.
4. IF an OTP expires after 5 minutes without being used, THEN THE Authentication_Service SHALL invalidate the OTP and require the user to request a new one.
5. WHEN a returning user with an active session opens the Customer App, THE Customer_App SHALL restore the session without requiring re-authentication.
6. THE Customer_App SHALL require users to provide a name and service address before completing their first booking.

---

### Requirement 2: Service Browsing and Selection

**User Story:** As a customer, I want to browse available service categories and select a specific service, so that I can initiate a booking for what I need.

#### Acceptance Criteria

1. WHEN a Customer opens the home screen, THE Customer_App SHALL display all available service categories including Cleaning, Waste Management, Logistics, B2B Services, and Recycling.
2. WHEN a Customer selects a service category, THE Customer_App SHALL display all sub-services within that category with name, description, and base price.
3. WHEN a Customer selects a sub-service, THE Customer_App SHALL initiate the booking flow for that service.
4. THE Customer_App SHALL display service availability based on the Customer's current zone.
5. IF no Workers are available in the Customer's zone for a selected service, THEN THE Customer_App SHALL notify the Customer and offer to schedule the service for a later time.

---

### Requirement 3: Booking Flow

**User Story:** As a customer, I want to complete a structured booking flow, so that I can provide all necessary details and confirm a service request.

#### Acceptance Criteria

1. WHEN a Customer initiates a booking, THE Booking_Service SHALL present a sequential flow: service selection → optional photo upload → location confirmation → price display → booking confirmation.
2. WHEN a Customer uploads a photo during booking, THE Booking_Service SHALL accept images in JPEG or PNG format up to 10MB in size.
3. IF a Customer uploads a file that is not JPEG or PNG or exceeds 10MB, THEN THE Booking_Service SHALL reject the upload and display a descriptive error message.
4. WHEN a Customer confirms their location, THE Customer_App SHALL display the confirmed address and allow the Customer to edit it before proceeding.
5. WHEN a Customer reaches the price display step, THE Booking_Service SHALL calculate and display the total price including base rate, any applicable surcharges, and taxes.
6. WHEN a Customer confirms a booking, THE Booking_Service SHALL create a Job record with status "pending" and return a unique Job ID to the Customer within 3 seconds.
7. IF a Customer abandons the booking flow before confirmation, THEN THE Booking_Service SHALL discard the incomplete booking and retain no partial records.

---

### Requirement 4: Worker Matching and Assignment

**User Story:** As a customer, I want to be matched with a nearby, qualified worker quickly, so that I receive service within the promised timeframe.

#### Acceptance Criteria

1. WHEN a Job is created with status "pending", THE Matching_Engine SHALL identify all available Workers in the same Zone who possess the required skill for the Job.
2. WHEN multiple Workers are eligible for a Job, THE Matching_Engine SHALL rank them by ascending distance from the Job location and assign the nearest available Worker.
3. WHEN a Worker is assigned to a Job, THE Matching_Engine SHALL update the Job status to "assigned" and notify both the Customer and the Worker within 5 seconds.
4. IF no eligible Worker is found within the Customer's Zone within 2 minutes, THEN THE Matching_Engine SHALL expand the search radius to adjacent Zones and retry.
5. IF no eligible Worker is found after expanding to adjacent Zones, THEN THE Matching_Engine SHALL update the Job status to "unassigned" and notify the Customer with an estimated wait time.
6. WHEN a Worker rejects an assigned Job, THE Matching_Engine SHALL immediately attempt to assign the next nearest eligible Worker.

---

### Requirement 5: Live Job Tracking

**User Story:** As a customer, I want to track my worker's location and job status in real time, so that I know when to expect service.

#### Acceptance Criteria

1. WHEN a Job status changes to "assigned", THE Tracking_Service SHALL begin broadcasting the assigned Worker's location to the Customer at intervals of no more than 10 seconds.
2. WHEN a Worker's location changes, THE Customer_App SHALL update the displayed map position within 10 seconds.
3. WHEN a Job status changes (assigned → en_route → in_progress → completed), THE Notification_Service SHALL send a push notification to the Customer describing the new status.
4. WHILE a Job is in status "in_progress", THE Customer_App SHALL display a live status indicator and the Worker's last known location.
5. WHEN a Job is completed, THE Tracking_Service SHALL stop broadcasting the Worker's location and update the Job status to "completed".

---

### Requirement 6: Job Completion and Proof Submission

**User Story:** As a worker, I want to upload before and after photos of a job, so that I can verify completion and protect against disputes.

#### Acceptance Criteria

1. WHEN a Worker marks a Job as started, THE Worker_App SHALL require the Worker to upload at least one "before" photo before the Job status changes to "in_progress".
2. WHEN a Worker marks a Job as complete, THE Worker_App SHALL require the Worker to upload at least one "after" photo before the Job status changes to "completed".
3. THE Booking_Service SHALL accept proof images in JPEG or PNG format up to 10MB per image.
4. IF a Worker attempts to mark a Job complete without uploading an "after" photo, THEN THE Worker_App SHALL block the action and display a descriptive error message.
5. WHEN proof images are uploaded, THE Booking_Service SHALL associate the images with the Job record and make them visible to the Customer and Admin.
6. WHEN a Job is marked "completed" with valid proof, THE Booking_Service SHALL trigger the earnings calculation for the Worker.

---

### Requirement 7: Worker Registration and KYC

**User Story:** As a worker, I want to register on the platform and complete identity verification, so that I can be approved to accept jobs.

#### Acceptance Criteria

1. WHEN a new Worker provides a valid phone number, THE Authentication_Service SHALL send an OTP to that phone number within 30 seconds.
2. WHEN a Worker completes OTP verification, THE Worker_App SHALL prompt the Worker to submit KYC documents including a government-issued ID and a selfie.
3. WHEN KYC documents are submitted, THE Admin_Panel SHALL make the submission available for Admin review within 60 seconds.
4. WHEN an Admin approves a Worker's KYC, THE Worker_Management_Service SHALL update the Worker's status to "verified" and notify the Worker.
5. IF an Admin rejects a Worker's KYC, THEN THE Worker_Management_Service SHALL update the Worker's status to "rejected", notify the Worker with a reason, and allow resubmission.
6. WHILE a Worker's status is not "verified", THE Matching_Engine SHALL exclude that Worker from all Job assignments.

---

### Requirement 8: Worker Job Management

**User Story:** As a worker, I want to view available jobs, accept or reject them, and manage my availability, so that I can control my workload and earnings.

#### Acceptance Criteria

1. WHEN a verified Worker opens the Worker App, THE Worker_App SHALL display a feed of Jobs available in the Worker's Zone that match the Worker's skills.
2. WHEN a Job is assigned to a Worker, THE Notification_Service SHALL send a push notification to the Worker within 5 seconds.
3. WHEN a Worker accepts a Job, THE Booking_Service SHALL update the Job status to "en_route" and notify the Customer.
4. WHEN a Worker rejects a Job, THE Booking_Service SHALL return the Job to "pending" status and trigger re-matching.
5. WHEN a Worker toggles the Availability_Toggle to "unavailable", THE Worker_Management_Service SHALL immediately remove the Worker from the eligible pool for new Job assignments.
6. WHEN a Worker toggles the Availability_Toggle to "available", THE Worker_Management_Service SHALL immediately add the Worker back to the eligible pool for Job assignments.
7. THE Worker_App SHALL display the Worker's current shift status, active Job details, and job history.

---

### Requirement 9: Worker Earnings

**User Story:** As a worker, I want to view my earnings in real time, so that I can track my income and understand my pay per job.

#### Acceptance Criteria

1. WHEN a Job is marked "completed", THE Earnings_Service SHALL calculate the Worker's earnings for that Job based on the service type and applicable rate.
2. WHEN earnings are calculated, THE Earnings_Service SHALL create an earnings record linked to the Worker and the Job.
3. THE Worker_App SHALL display the Worker's total earnings for the current day, current week, and all time.
4. WHEN a Worker views a completed Job in their history, THE Worker_App SHALL display the earnings amount for that specific Job.
5. THE Earnings_Service SHALL apply the platform commission rate to each Job before crediting the Worker's earnings.

---

### Requirement 10: Admin Job Management

**User Story:** As an admin, I want to create, assign, and monitor all jobs on the platform, so that I can ensure operational efficiency and service quality.

#### Acceptance Criteria

1. WHEN an Admin creates a Job manually, THE Admin_Panel SHALL require service type, customer location, and scheduled time before creating the Job record.
2. WHEN an Admin assigns a Worker to a Job manually, THE Admin_Panel SHALL validate that the Worker is verified, available, and possesses the required skill before confirming the assignment.
3. WHEN an Admin views the job dashboard, THE Admin_Panel SHALL display all Jobs with their current status, assigned Worker, customer location, and service type.
4. WHEN an Admin filters Jobs by status, THE Admin_Panel SHALL return only Jobs matching the selected status within 2 seconds.
5. THE Admin_Panel SHALL allow Admins to update the status of any Job at any time with a mandatory reason field.

---

### Requirement 11: Admin Worker Management

**User Story:** As an admin, I want to manage worker profiles, verify KYC, and monitor performance, so that I can maintain a high-quality workforce.

#### Acceptance Criteria

1. WHEN an Admin views the worker dashboard, THE Admin_Panel SHALL display all Workers with their verification status, zone, skills, rating, and availability.
2. WHEN an Admin adds a new Worker manually, THE Admin_Panel SHALL require name, phone number, zone, and at least one skill before creating the Worker record.
3. WHEN an Admin reviews a KYC submission, THE Admin_Panel SHALL display the submitted government ID and selfie side by side for comparison.
4. THE Admin_Panel SHALL allow Admins to assign or reassign a Worker's Zone at any time.
5. WHEN an Admin views a Worker's profile, THE Admin_Panel SHALL display the Worker's job completion rate, average rating, total earnings, and number of jobs completed.

---

### Requirement 12: Admin Analytics

**User Story:** As an admin, I want to view platform analytics, so that I can monitor business performance and make data-driven decisions.

#### Acceptance Criteria

1. WHEN an Admin opens the analytics dashboard, THE Admin_Panel SHALL display total jobs completed, total revenue, total waste processed, and active worker count for the selected time period.
2. THE Admin_Panel SHALL allow Admins to filter analytics by date range, zone, and service type.
3. WHEN an Admin exports analytics data, THE Admin_Panel SHALL generate a CSV file containing the filtered data within 10 seconds.
4. THE Admin_Panel SHALL update analytics figures at intervals of no more than 5 minutes.

---

### Requirement 13: Pricing Management

**User Story:** As an admin, I want to set and update service rates, so that I can control platform pricing and margins.

#### Acceptance Criteria

1. WHEN an Admin sets a price for a service type, THE Pricing_Service SHALL store the base rate, applicable taxes, and any zone-specific surcharges.
2. WHEN a Customer initiates a booking, THE Pricing_Service SHALL apply the current rate for the selected service type and zone.
3. WHEN an Admin updates a service rate, THE Pricing_Service SHALL apply the new rate to all Jobs created after the update time and leave existing Jobs unaffected.
4. THE Admin_Panel SHALL display the current rate for every service type and allow inline editing.

---

### Requirement 14: Notification System

**User Story:** As a user (customer or worker), I want to receive timely push notifications about job status changes, so that I am always informed without needing to check the app manually.

#### Acceptance Criteria

1. WHEN a Job is confirmed, THE Notification_Service SHALL send a "Job Confirmed" push notification to the Customer within 5 seconds.
2. WHEN a Worker is assigned to a Job, THE Notification_Service SHALL send a "Worker Assigned" push notification to the Customer and a "New Job" push notification to the Worker within 5 seconds.
3. WHEN a Worker's status changes to "en_route", THE Notification_Service SHALL send a "Worker Arriving" push notification to the Customer within 5 seconds.
4. WHEN a Job status changes to "completed", THE Notification_Service SHALL send a "Job Completed" push notification to the Customer within 5 seconds.
5. IF a push notification fails to deliver, THEN THE Notification_Service SHALL retry delivery up to 3 times with exponential backoff before logging the failure.

---

### Requirement 15: Customer Rewards and Eco Score

**User Story:** As a customer, I want to earn points and track my eco score, so that I am rewarded for using environmentally positive services.

#### Acceptance Criteria

1. WHEN a Customer completes a booking for an eco-classified service (Eco Cleaning, Recycling, E-waste collection), THE Rewards_Service SHALL award the Customer a defined number of Eco Points.
2. WHEN Eco Points are awarded, THE Rewards_Service SHALL update the Customer's Eco_Score and notify the Customer of the new total.
3. THE Customer_App SHALL display the Customer's current Eco Points balance and Eco_Score on the rewards screen.
4. WHEN a Customer redeems Eco Points, THE Rewards_Service SHALL deduct the redeemed amount from the Customer's balance and apply the corresponding discount to the next eligible booking.
5. IF a Customer attempts to redeem more Eco Points than their current balance, THEN THE Rewards_Service SHALL reject the redemption and display the available balance.

---

### Requirement 16: Offline Mode

**User Story:** As a worker, I want the app to function in areas with poor connectivity, so that I can continue working without interruption.

#### Acceptance Criteria

1. WHILE a Worker has an active Job and loses internet connectivity, THE Worker_App SHALL retain the current Job details locally and allow the Worker to continue navigating and updating job status.
2. WHEN internet connectivity is restored, THE Worker_App SHALL synchronize all locally stored status updates and proof uploads with the server.
3. IF synchronization fails after connectivity is restored, THEN THE Worker_App SHALL retry synchronization up to 5 times with exponential backoff and alert the Worker if all retries fail.
4. WHILE offline, THE Worker_App SHALL display a visible connectivity status indicator to the Worker.

---

### Requirement 17: B2B Service Contracts

**User Story:** As an admin, I want to manage B2B contracts with businesses and residential societies, so that I can support recurring enterprise clients.

#### Acceptance Criteria

1. WHEN an Admin creates a B2B_Contract, THE Admin_Panel SHALL require client name, service scope, zone, contract start date, contract end date, and monthly rate.
2. WHEN a B2B_Contract is active, THE Booking_Service SHALL automatically generate recurring Jobs according to the contract schedule.
3. WHEN a B2B_Contract expires, THE Booking_Service SHALL stop generating Jobs for that contract and notify the Admin.
4. THE Admin_Panel SHALL display all active, expired, and pending B2B_Contracts with their key details.

---

### Requirement 18: Recycling and Waste Monetization

**User Story:** As a customer, I want to submit recyclable waste and receive cash or points in return, so that I can benefit financially from responsible waste disposal.

#### Acceptance Criteria

1. WHEN a Customer selects the Recycling service, THE Customer_App SHALL display accepted waste categories (scrap metal, paper, plastic, e-waste) with current buy rates per kilogram.
2. WHEN a Customer books a recycling pickup, THE Booking_Service SHALL create a Job of type "recycling" and assign a Worker with the "recycling" skill.
3. WHEN a recycling Job is completed, THE Recycling_Service SHALL record the weight and category of waste collected as entered by the Worker.
4. WHEN waste weight and category are recorded, THE Recycling_Service SHALL calculate the payout amount and credit it to the Customer's account as cash or Eco Points based on the Customer's preference.
5. IF the Customer's preferred payout method is cash, THEN THE Recycling_Service SHALL initiate a transfer to the Customer's registered payment method within 24 hours.
