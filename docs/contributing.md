# Contributing to RiverFlow Sentinel

Thank you for contributing to RiverFlow Sentinel.
This guide defines the expected workflow, coding standards, and pull request process.

## 1. Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Git
- Firebase CLI (for backend/security deployments)

## 2. Clone and Setup

```bash
git clone https://github.com/Mazt08/RiverFlow.git
cd RiverFlow
flutter pub get
```

Optional (Firebase):

```bash
flutterfire configure
```

## 3. Run the Project

```bash
flutter run
```

For targeted platform runs:

```bash
flutter run -d android
flutter run -d chrome
```

## 4. Branching Workflow

1. Create a feature/fix branch from the active integration branch.
2. Use clear branch names:
   - `feature/<scope>`
   - `fix/<scope>`
   - `docs/<scope>`
3. Keep commits focused and descriptive.

## 5. Coding Standards

- Follow Dart analyzer and lint rules (`flutter_lints`).
- Prefer small, composable widgets.
- Keep business logic in `services/`, not in UI widgets.
- Use meaningful names and avoid dead/unused code.
- Preserve existing project architecture and naming conventions.

## 6. Pull Request Process

1. Sync with latest target branch.
2. Run checks locally:

```bash
flutter pub get
flutter analyze
flutter test
```

3. Open PR with:

- concise summary
- screenshots/GIF for UI changes
- testing notes
- linked issue/task

4. Ensure at least one reviewer approval before merge.

## 7. Documentation Requirements

- Update docs when changing architecture, APIs, or flows.
- Include database/rules updates when schema or permissions change.
- Keep changelog entries concise and versioned.

## 8. Security and Data Safety

- Never commit secrets, API keys, or service account files.
- Apply least-privilege principle in Firebase Rules.
- Validate all critical writes and role-based operations.
- Route sensitive operations through trusted backend logic when possible.

## 9. Issue Reporting

When reporting a bug, include:

- platform/device info
- reproduction steps
- expected vs actual behavior
- relevant logs or screenshots

## 10. Code of Collaboration

- Be respectful and constructive in reviews.
- Prefer evidence-based technical decisions.
- Prioritize reliability and public safety outcomes for flood monitoring features.
