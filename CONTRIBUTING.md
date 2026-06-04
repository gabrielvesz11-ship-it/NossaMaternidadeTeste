# Contributing

This repository is the canonical Nossa Maternidade codebase. Contributions must improve this repo directly; do not create clone repositories for experiments.

## Workflow

1. Create or link an issue.
2. Branch from `main`.
3. Keep the diff small enough for review.
4. Run local quality checks.
5. Open a pull request.
6. Wait for CI and review before merge.

Direct pushes to `main` are not allowed.

## Local Checks

```bash
scripts/quality-check.sh
```

If the environment cannot run a simulator build, state the exact blocker in the pull request.

## Code Standards

- Prefer small SwiftUI views and feature-local helpers.
- Keep functions under 40 lines where practical.
- Avoid `try!`, force unwraps, force casts, and production `fatalError`.
- Keep product copy in PT-BR.
- Keep secrets out of source code and logs.
- Add tests for business logic, config behavior, service errors, and regressions.

## Pull Request Expectations

Every PR must include:

- What changed.
- Why it changed.
- How it was tested.
- Screenshots or screen recordings for UI changes.
- Explicit note if config, Supabase schema, auth, payment, or AI behavior is touched.

## Architecture Rules

- `Core` owns shared platform concerns: config, networking, persistence, design, navigation, service composition.
- `Features` own user-facing flows and should not import other features directly.
- `Models` contains shared SwiftData/domain models.
- External SDKs and network calls must sit behind service boundaries.

## Sensitive Areas

Ask for explicit review before changing:

- Auth/session behavior.
- Payment/subscription behavior.
- Supabase schema or RLS policies.
- NathIA safety prompt or production AI routing.
- Any file that may contain secrets or build configuration.
