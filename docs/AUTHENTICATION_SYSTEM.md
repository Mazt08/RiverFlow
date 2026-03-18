# Authentication System

## Overview

RiverFlow Sentinel uses Firebase Authentication for identity management, account security, and role-based access control.

## Supported Account Roles

- `admin` - operational monitoring, broadcast management, user oversight
- `user` - resident monitoring, alerts, and message consumption

Role values are stored in `users/{uid}/role` and should also be mirrored through custom claims for stronger security where possible.

## Login Process

1. User enters email and password.
2. App validates input format.
3. Firebase Auth verifies credentials.
4. App fetches user profile from `users/{uid}`.
5. Role determines navigation target:
   - Admin shell/dashboard
   - User shell/dashboard

## Registration Process

1. User submits name, email, and password.
2. App creates Firebase Auth account.
3. Profile is inserted into `users/{uid}` with default role `user`.
4. `createdAt` timestamp is recorded.
5. Verification email is sent automatically.

## Email Verification

- New users should verify email before full access.
- App should check `emailVerified` on login/session restore.
- Unverified users can be restricted to a limited state until verification is complete.

## Password Reset

- User provides registered email on reset screen.
- App calls Firebase password reset API.
- Firebase sends reset link securely to inbox.

## Session Handling

- Use Firebase ID tokens for authenticated API/database access.
- Persist session across app restarts using Firebase Auth state listeners.
- Handle token refresh and sign-out cleanly.

## Admin Account Provisioning

Admin accounts are created manually through one of the following secure methods:

1. Firebase Console user creation + profile role set to `admin`.
2. Admin SDK / Cloud Function onboarding script.
3. Optional custom claim assignment (`admin: true`) for rules simplification.

Only trusted maintainers should have permission to grant admin role.

## User Registration Policy

- Residents register directly from the app (self-service).
- Default assigned role must always be `user`.
- Role escalation should never be exposed in client UI.

## Security Best Practices

- Enforce minimum password policy.
- Rate-limit login attempts where possible.
- Require verified email for sensitive operations.
- Keep authorization checks in both app logic and Firebase Security Rules.
