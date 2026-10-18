# Tasks

## Task List

- [x] 1. Consolidate and scaffold the unified Flutter customer app
  - [x] 1.1 Merge `flutter/ecomins_customer/` as the canonical app (it has the cleaner feature-based structure)
  - [x] 1.2 Add `web_socket_channel` dependency to `pubspec.yaml` for live tracking
  - [x] 1.3 Create `lib/core/constants.dart` with backend base URLs and zone constants
  - [x] 1.4 Fix existing lint issues: replace `CardTheme` with `CardThemeData`, replace `withOpacity` with `withValues`

- [x] 2. Auth feature — complete and harden
  - [x] 2.1 Extend `AuthProvider` with `customerName`, `customerAddress`, `hasProfile` fields and `saveProfile()` method
  - [x] 2.2 Persist `customerName` and `customerAddress` in `SharedPreferences` alongside token
  - [x] 2.3 Add loading state to `_Root` widget to prevent auth screen flash on cold launch (Requirement 1.3)
  - [x] 2.4 Write widget tests for `PhoneScreen` and `OtpScreen` covering validation and error states

- [x] 3. Profile screen
  - [x] 3.1 Create `lib/features/profile/profile_screen.dart` with name and address fields and a Save button
  - [x] 3.2 Wire profile screen into `HomeScreen` bottom nav as the 4th destination (Requirement 8.1)
  - [x] 3.3 Add profile gate in `BookingScreen` step 2: if `!auth.hasProfile`, push `ProfileScreen` before confirming (Requirement 1.6, 7.3)

- [x] 4. Services screen — polish
  - [x] 4.1 Replace `withOpacity` with `withValues` in `_CategoryCard` gradient (lint fix)
  - [x] 4.2 Add sub-service count badge to each category card (Requirement 2.3)
  - [x] 4.3 Write widget test verifying all 5 categories render

- [x] 5. Booking feature — BookingProvider + screen
  - [x] 5.1 Create `lib/features/booking/booking_provider.dart` with `BookingStatus` enum and all state fields
  - [x] 5.2 Implement `fetchPrice()` with ₦500 fallback and visible warning on failure (Requirement 3.3, 3.8)
  - [x] 5.3 Implement `createJob()` with loading guard to prevent duplicate submissions (Requirement 3.6)
  - [x] 5.4 Implement `reset()` to clear booking state on back-navigation (Requirement 3.9)
  - [x] 5.5 Refactor `BookingScreen` to consume `BookingProvider` via `context.watch`
  - [x] 5.6 Add step 2 summary row for all fields: sub-service, category, address, price, zone (Requirement 3.5)
  - [x] 5.7 Write widget tests for step validation (step 0 no service, step 1 no address)

- [x] 6. Tracking feature — TrackingProvider + screen
  - [x] 6.1 Create `lib/features/tracking/tracking_provider.dart` with WebSocket connection logic
  - [x] 6.2 Implement `startTracking()` connecting to `ws://host:3006/track/job/{jobId}`
  - [x] 6.3 Implement WebSocket message handler: parse status + location, validate forward-only transitions, append to `statusHistory`
  - [x] 6.4 Implement auto-reconnect: up to 5 attempts with 3s delay, set `isConnected` flag (Requirement 4.6)
  - [x] 6.5 Create `lib/features/tracking/tracking_screen.dart` showing status timeline and worker location text
  - [x] 6.6 Show "Reconnecting…" indicator when `isConnected` is false (Requirement 4.6)
  - [x] 6.7 Show completion UI and "Back to Home" button when status = completed (Requirement 4.5)
  - [x] 6.8 Write unit tests for `TrackingProvider`: status transition validation, append-only history, reconnect logic

- [x] 7. Orders feature — OrdersProvider + screen
  - [x] 7.1 Create `lib/features/orders/orders_provider.dart` with `loadJobs()` and `refresh()`
  - [x] 7.2 Move `OrdersScreen` from `ecomins_customer` (currently missing) — create `lib/features/orders/orders_screen.dart` based on `customer_app` implementation
  - [x] 7.3 Add tap handler on active jobs to navigate to `TrackingScreen` (Requirement 5.5)
  - [x] 7.4 Write widget tests for empty state and list rendering

- [x] 8. Rewards feature — RewardsProvider + screen
  - [x] 8.1 Create `lib/features/rewards/rewards_provider.dart` with `loadRewards()` and `redeemPoints()` with client-side balance guard
  - [x] 8.2 Move `RewardsScreen` to `lib/features/rewards/rewards_screen.dart`
  - [x] 8.3 Add "Redeem Points" UI with amount input and balance guard (Requirement 6.3, 6.4)
  - [x] 8.4 Write unit tests for `RewardsProvider`: balance guard, redemption flow

- [x] 9. API layer — extend and type `core/api.dart`
  - [x] 9.1 Return typed `PricingResult` from `getPrice()` instead of raw `double`
  - [x] 9.2 Return typed `List<Job>` from `getJobs()` using `Job.fromJson()`
  - [x] 9.3 Return typed `RewardsAccount` from `getRewards()`
  - [x] 9.4 Add `redeemPoints()` method calling `POST /rewards/{customerId}/redeem`
  - [x] 9.5 Add `connectTracking()` returning a `WebSocketChannel` for the tracking-service
  - [x] 9.6 Add `constants.dart` with configurable base URLs (Android emulator vs iOS simulator vs production)

- [x] 10. Data models
  - [x] 10.1 Create `lib/models/job.dart` with `Job` class, `JobStatus` enum, and `Job.fromJson()`
  - [x] 10.2 Create `lib/models/pricing_result.dart` with `PricingResult.fromJson()`
  - [x] 10.3 Create `lib/models/rewards_account.dart` with `RewardsAccount.fromJson()`
  - [x] 10.4 Create `lib/models/status_event.dart` with `StatusEvent` for tracking timeline

- [x] 11. HomeScreen — update bottom nav to 4 tabs
  - [x] 11.1 Add Profile destination to `NavigationBar` (Requirement 8.1)
  - [x] 11.2 Fix missing `OrdersScreen` and `RewardsScreen` imports (currently broken in `ecomins_customer`)
  - [x] 11.3 Register `BookingProvider`, `TrackingProvider`, `OrdersProvider`, `RewardsProvider` in `MultiProvider` in `main.dart`

- [x] 12. Integration and end-to-end tests
  - [x] 12.1 Write integration test: cold launch with stored token → HomeScreen (no auth screens shown)
  - [x] 12.2 Write integration test: full booking flow PhoneScreen → OtpScreen → ServicesScreen → BookingScreen → TrackingScreen
  - [x] 12.3 Write integration test: rewards redemption — load balance → over-redemption rejected → successful redemption
