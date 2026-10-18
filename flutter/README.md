# Ecomins Flutter Frontend

Three Flutter apps connecting to the Node.js backend services.

## Apps

| App | Target | Port mapping |
|---|---|---|
| `customer_app` | Android / iOS | Auth: 3001, Booking: 3002 |
| `worker_app` | Android / iOS | Auth: 3001, Worker: 3003 |
| `admin_panel` | Web | All services on localhost |

## Run the backend first

From the monorepo root:
```bash
# Terminal 1 — Auth
cd packages/auth-service && npx tsx src/index.ts

# Terminal 2 — Booking
cd packages/booking-service && npx tsx src/server.ts

# Terminal 3 — Worker
cd packages/worker-service && npx tsx src/index.ts

# Terminal 4 — Pricing
cd packages/pricing-service && npx tsx src/index.ts
```

## Run Customer App (Android emulator)

```bash
cd flutter/customer_app
flutter pub get
flutter run
```

The app uses `http://10.0.2.2:PORT` which maps to `localhost` on Android emulator.
For iOS simulator change to `http://localhost:PORT` in `lib/services/api_service.dart`.

## Run Worker App

```bash
cd flutter/worker_app
flutter pub get
flutter run
```

## Run Admin Panel (Web)

```bash
cd flutter/admin_panel
flutter pub get
flutter run -d chrome
```

Admin panel uses `http://localhost:PORT` directly since it runs in the browser.

## OTP flow (dev)

Since SMS is stubbed, the OTP is printed to the auth-service console:
```
[SMS] Sending OTP 123456 to +2348012345678
```
Copy that code into the OTP screen.
