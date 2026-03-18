# RiverFlow Teammate Handoff

## 1) What was done from the start

This project was migrated from Realtime Database usage to Cloud Firestore with role-based access.

### Completed work summary

- Migrated app data services to Cloud Firestore.
- Connected and used these collections:
  - `users`
  - `river_data`
  - `messages`
  - `notification_tokens`
- Implemented Firestore-based role authorization (`users/{uid}.role`) instead of custom claims for Spark-plan compatibility.
- Updated Firestore security rules with admin checks via `isAdmin()`.
- Added/updated app services:
  - `AuthService`
  - `FirestoreService`
  - `RiverDataService`
  - `MessageService`
- Added login/register flow improvements including profile creation in Firestore after registration.
- Added verification logic adjustments (admin bypass support, user verification enforcement).
- Added loading/fallback fixes so Dashboard/Messages/Analytics do not stay in infinite loading when streams are empty or fail.
- Added Firebase deploy config updates in `firebase.json`.

### Current role-routing behavior

- Login routes to:
  - `/admin` if user role is `admin`
  - `/user` otherwise
- Admin role is read from Firestore user profile (`users/{uid}` document).

---

## 2) Teammate setup commands (terminal)

Run these commands from project root (`RiverFlow`).

### A. Flutter app dependencies

```bash
flutter pub get
```

### B. Cloud Functions dependencies

```bash
cd functions
npm install
cd ..
```

### C. Verify tooling

```bash
flutter --version
firebase --version
node --version
npm --version
```

### D. Run static analysis

```bash
flutter analyze
```

### E. Run app (web)

```bash
flutter run -d chrome
```

---

## 3) Firebase project setup checklist

1. Firebase project selected: `riverflow-sentinel`.
2. Firestore rules deployed:

```bash
firebase deploy --only firestore:rules
```

3. Authentication Email/Password enabled.
4. For admin access, ensure the user has Firestore profile:
   - Collection: `users`
   - Document ID: user's auth UID
   - Required field: `role: "admin"`

---

## 4) Common recovery commands

### Refresh packages after pull

```bash
flutter pub get
cd functions && npm install && cd ..
```

### Clean + rebuild if local environment is broken

```bash
flutter clean
flutter pub get
```

---

## 5) Branch workflow used in this update

- Working branch: `ext`
- Changes committed and pushed to `origin/ext`
- Merged `ext` into `main`
- Pushed merged `main` to `origin/main`
