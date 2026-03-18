# Messaging System

## Overview

RiverFlow Sentinel includes an emergency broadcast module that allows administrators to communicate critical flood-related updates to residents.

## Core Messaging Capabilities

- Admin-authored broadcast messages
- In-app message history feed for users
- Push notification delivery via Firebase Cloud Messaging (FCM)

## Admin Broadcast Flow

1. Admin enters advisory/warning text in the broadcast screen.
2. Message severity is selected (`info`, `advisory`, `warning`, `emergency`).
3. Message is written to `messages/{message_id}`.
4. Backend trigger sends FCM notification to recipients.
5. Users receive push + in-app feed update.

## User Message Consumption

- Users can review current and previous advisories in message history.
- Messages are sorted by `timestamp` descending.
- Severity tags enable quick prioritization of high-risk notices.

## Example Message Format

```text
⚠️ RiverFlow Alert
River level rising rapidly. Prepare evacuation.
```

## FCM Notification Model

### Topic-Based (recommended)

- Residents subscribe to barangay-specific or global alert topics.
- Admin broadcasts publish once to topic.
- Efficient for one-to-many emergency communication.

### Token-Based (optional)

- Store tokens under `notification_tokens/{uid}`.
- Allows targeted notifications (e.g., responder teams).

## Delivery and Reliability Practices

- Include clear, concise title + action statement.
- Add deep-link metadata to open message screen directly.
- Retry failed sends from backend queue when needed.
- Log send outcome for incident review.

## Security Requirements

- Only admin users can create/update/delete `messages/` entries.
- All authenticated users can read published messages.
- Message write actions should be auditable with sender UID and timestamp.

## Recommended Severity Guidance

- `info`: status updates, no immediate action
- `advisory`: stay alert and monitor updates
- `warning`: prepare household evacuation plans
- `emergency`: immediate evacuation required
