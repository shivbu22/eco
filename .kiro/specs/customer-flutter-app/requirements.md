# Requirements Document

## Introduction

This document defines the requirements for the Ecomins Customer Flutter App — the "10-min app" — which allows customers to book on-demand home services (cleaning, waste management, logistics, B2B, recycling) and receive a worker assignment within 10 minutes. The app consolidates two existing partial Flutter implementations (`flutter/ecomins_customer/` and `flutter/customer_app/`) into a single production-ready application backed by the existing Node.js microservices.

---

## Requirements

### Requirement 1: Authentication and Session Management

**User Story:** As a customer, I want to log in with my phone number and OTP, and have my session restored automatically, so that I don't need to re-authenticate every time I open the app.

#### Acceptance Criteria

1. WHEN a customer enters a valid phone number and taps "Send OTP", THE Customer_App SHALL call the auth-service and display the OTP entry screen within 3 seconds.
2. WHEN a customer submits a correct 6-digit OTP, THE Customer_App SHALL store the returned JWT token in local storage and navigate to the home screen.
3. WHEN a customer opens the app with a previously stored token, THE Customer_App SHALL restore the session and navigate directly to the home screen without showing the auth flow.
4. WHEN a customer taps "Logout", THE Customer_App SHALL clear the stored token and navigate to the phone entry screen.
5. IF an OTP submission fails (wrong OTP, expired, or locked), THEN THE Customer_App SHALL display a descriptive error message via a SnackBar and allow the customer to retry.
6. WHEN a customer completes OTP verification for the first time, THE Customer_App SHALL prompt the customer to enter their name and service address before allowing a booking to be confirmed.

---

### Requirement 2: Service Discovery

**User Story:** As a customer, I want to browse all available service categories and their sub-services, so that I can find and select the service I need.

#### Acceptance Criteria

1. WHEN a customer opens the Services tab, THE Customer_App SHALL display all five service categories: Cleaning, Waste Management, Logistics, B2B Services, and Recycling, as a 2-column grid.
2. WHEN a customer taps a service category card, THE Customer_App SHALL navigate to the booking flow and display the sub-services for that category in step 0.
3. THE Customer_App SHALL display the number of sub-services available within each category card.
4. IF the backend indicates no workers are available in the customer's zone for a selected service, THEN THE Customer_App SHALL display a "No workers available" message and offer to schedule for a later time.

---

### Requirement 3: Booking Flow

**User Story:** As a customer, I want to complete a guided booking flow, so that I can select a service, confirm my address, review the price, and submit a booking in under 2 minutes.

#### Acceptance Criteria

1. WHEN a customer enters the booking flow, THE Customer_App SHALL present a 3-step Stepper: (0) Select Sub-Service → (1) Address & Price → (2) Confirm & Submit.
2. WHEN a customer attempts to advance from step 0 without selecting a sub-service, THE Customer_App SHALL block the advance and display "Select a service".
3. WHEN a customer advances from step 0, THE Customer_App SHALL fetch the estimated price from the pricing-service and display it in step 1 before the customer can proceed.
4. WHEN a customer attempts to advance from step 1 without entering an address, THE Customer_App SHALL block the advance and display "Enter your address".
5. WHEN a customer reaches step 2, THE Customer_App SHALL display a summary showing: selected sub-service, category, address, estimated price, and zone.
6. WHEN a customer taps "Confirm Booking", THE Customer_App SHALL call the booking-service to create a Job and navigate to the Tracking screen within 3 seconds.
7. IF the booking-service returns an error, THEN THE Customer_App SHALL display the error message via a SnackBar and remain on the confirmation step.
8. IF the pricing-service is unreachable, THEN THE Customer_App SHALL display a fallback price of ₦500.00 with a visible warning and allow the customer to proceed.
9. WHEN a customer navigates away from the booking flow before confirming, THE Customer_App SHALL discard all entered booking data.

---

### Requirement 4: Live Job Tracking

**User Story:** As a customer, I want to see my worker's live location and job status updates after booking, so that I know exactly when to expect service.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE Customer_App SHALL navigate to the Tracking screen and display the current job status.
2. WHEN the tracking-service sends a location update via WebSocket, THE Customer_App SHALL update the displayed worker position within 10 seconds.
3. WHEN the job status changes (assigned → en_route → in_progress → completed), THE Customer_App SHALL append the new status to a visible status timeline on the Tracking screen.
4. WHILE a job is in "in_progress" status, THE Customer_App SHALL display a live status indicator and the worker's last known location.
5. WHEN the job status reaches "completed", THE Customer_App SHALL display a completion confirmation and provide a button to return to the home screen.
6. IF the WebSocket connection drops, THEN THE Customer_App SHALL attempt to reconnect automatically up to 5 times with a 3-second delay and display a "Reconnecting…" indicator during reconnection attempts.

---

### Requirement 5: Order History

**User Story:** As a customer, I want to view all my past and active bookings, so that I can track my service history and check the status of ongoing jobs.

#### Acceptance Criteria

1. WHEN a customer opens the Orders tab, THE Customer_App SHALL fetch and display all jobs associated with the customer's account.
2. WHEN jobs are displayed, THE Customer_App SHALL show each job's service type, address, and current status with a color-coded status chip.
3. IF the customer has no orders, THEN THE Customer_App SHALL display an empty state with an icon and "No orders yet" message.
4. WHEN a customer pulls down on the Orders list, THE Customer_App SHALL refresh the job list from the booking-service.
5. WHEN a customer taps an active job (status not "completed" or "cancelled"), THE Customer_App SHALL navigate to the Tracking screen for that job.

---

### Requirement 6: Rewards and Eco Score

**User Story:** As a customer, I want to view my Eco Points balance and Eco Score, and redeem points for discounts, so that I am rewarded for using eco-friendly services.

#### Acceptance Criteria

1. WHEN a customer opens the Rewards tab, THE Customer_App SHALL fetch and display the customer's current Eco Points balance and Eco Score from the rewards-service.
2. WHEN a customer completes a booking for an eco-classified service (Eco Cleaning, Recycling, E-waste Collection), THE Customer_App SHALL reflect the updated Eco Points balance after the job is completed.
3. WHEN a customer taps "Redeem Points", THE Customer_App SHALL display the available balance and allow the customer to enter a redemption amount.
4. IF a customer attempts to redeem more points than their current balance, THEN THE Customer_App SHALL block the redemption before making an API call and display "Insufficient Eco Points".
5. WHEN a redemption is successful, THE Customer_App SHALL update the displayed balance immediately and show a confirmation message.

---

### Requirement 7: Profile Management

**User Story:** As a customer, I want to view and update my name and service address, so that my bookings are pre-filled with accurate information.

#### Acceptance Criteria

1. WHEN a customer opens the Profile screen, THE Customer_App SHALL display the customer's stored name and service address.
2. WHEN a customer updates their name or address and taps "Save", THE Customer_App SHALL persist the changes to local storage and confirm with a SnackBar.
3. WHEN a customer has not yet set their name and address, THE Customer_App SHALL display the Profile screen as a required step before the booking confirmation step can be reached.

---

### Requirement 8: Navigation and App Shell

**User Story:** As a customer, I want a clear and consistent navigation structure, so that I can move between services, orders, rewards, and my profile without confusion.

#### Acceptance Criteria

1. WHEN a customer is authenticated, THE Customer_App SHALL display a bottom navigation bar with four destinations: Services, Orders, Rewards, and Profile.
2. WHEN a customer taps a bottom navigation destination, THE Customer_App SHALL switch to the corresponding screen without losing the state of other tabs.
3. THE Customer_App SHALL use the Ecomins green color palette (primary: #2E7D32) and Material 3 design system consistently across all screens.
4. WHEN the app is loading initial data (auth restore, first data fetch), THE Customer_App SHALL display a centered loading indicator and not flash the auth screen.
