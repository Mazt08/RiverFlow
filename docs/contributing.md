# Contributing

Guidelines for contributing to RiverFlow Sentinel.

---

## Branching Strategy

| Branch           | Purpose                                      |
| ---------------- | -------------------------------------------- |
| `main`           | Stable, production-ready code                |
| `feature/<name>` | New features (e.g., `feature/firebase-auth`) |
| `fix/<name>`     | Bug fixes (e.g., `fix/login-validation`)     |
| `admin-side`     | Admin-specific feature work                  |

**Never commit directly to `main`.** Always work on a branch and open a pull request.

---

## Workflow

1. Pull the latest `main`:
   ```bash
   git checkout main
   git pull origin main
   ```
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes, then commit with a clear message:
   ```bash
   git add .
   git commit -m "feat: add Firebase auth integration"
   ```
4. Push your branch and open a Pull Request on GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```
5. After the PR is reviewed and merged, delete the branch.

---

## Commit Message Format

Use short, descriptive prefixes:

| Prefix      | When to use                                  |
| ----------- | -------------------------------------------- |
| `feat:`     | Adding a new feature                         |
| `fix:`      | Fixing a bug                                 |
| `refactor:` | Restructuring code without changing behavior |
| `docs:`     | Documentation only                           |
| `style:`    | Formatting, no logic change                  |
| `test:`     | Adding or updating tests                     |
| `chore:`    | Build config, pubspec changes                |

Example: `feat: add messaging screen to user shell`

---

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) conventions
- Run `dart format .` before committing
- Keep widgets small and single-purpose — extract to `widgets/` when a widget is used in more than one screen
- Services must remain singletons; don't instantiate them with `new`
- Never hardcode credentials — use `AppConfig` or environment variables

---

## Running Tests

```bash
flutter test
```

All tests must pass before opening a pull request.

---

## Reporting Issues

Open an issue on GitHub with:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Flutter/Dart version (`flutter --version`)
