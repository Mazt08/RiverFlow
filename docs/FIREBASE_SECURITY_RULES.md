# Firebase Cloud Firestore Security Rules

## Objective

Secure RiverFlow Sentinel data by enforcing authenticated access, role-based permissions, and strict write boundaries for operational safety using Firestore rules.

## Source of Truth

The active production rules are in `firestore.rules` at the project root.

## Recommended Firestore Access Model

- `users/{uid}`: user can read/write own profile; admins (`request.auth.token.admin == true`) can manage all.
- `river_data/{doc}`: authenticated users can read; only admins can write.
- `messages/{doc}`: authenticated users can read; only admins can write.
- default deny for any unspecified path.

## Deployment

```bash
firebase deploy --only firestore:rules
```

## Security Hardening Recommendations

- Keep admin-only writes behind custom claims (`admin: true`).
- Move sensor writes to a trusted backend (Cloud Functions/Admin SDK).
- Add App Check to reduce abuse from unauthorized clients.
- Enable audit logging for admin write events.
