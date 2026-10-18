# Firebase Backend — Ecomins

Cloud Functions for booking, rewards, and tracking services.
Auth and pricing still run as local Node.js services.

## Functions

| Function  | Routes                                          | Port (emulator) |
|-----------|-------------------------------------------------|-----------------|
| `jobs`    | POST/GET /jobs, GET/PATCH /jobs/:id             | 5001            |
| `rewards` | GET /rewards/:id, POST /rewards/:id/award|redeem | 5001          |
| `tracking`| POST/GET /tracking/:jobId/location              | 5001            |

## Setup (one-time)

1. Install Firebase CLI:
   ```
   npm install -g firebase-tools
   ```

2. Login:
   ```
   firebase login
   ```

3. Create a Firebase project at https://console.firebase.google.com
   - Enable Firestore (Native mode)
   - Note your Project ID

4. Update `.firebaserc` with your project ID:
   ```json
   { "projects": { "default": "YOUR_PROJECT_ID" } }
   ```

5. Update `flutter/ecomins_customer/lib/core/api.dart`:
   - Replace `ecomins-app` in `_fbBase` with your project ID

6. Install function dependencies:
   ```
   cd firebase/functions
   npm install
   ```

## Run locally (emulator)

```
cd firebase
firebase emulators:start
```

Emulator UI: http://localhost:4000
Functions: http://localhost:5001

## Deploy to production

```
cd firebase
firebase deploy --only functions
```

Then update `_fbBase` in `api.dart` to:
```
https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net
```
