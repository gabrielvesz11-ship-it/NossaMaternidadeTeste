# Nossa Maternidade

Nossa Maternidade is the canonical iOS codebase for the maternity and parenting product family under `gabrielvesz11-ship-it`.

The current repository name is `NossaMaternidadeTeste`; after consolidation, the intended public name is `NossaMaternidade`. All new product work should happen here through pull requests.

## Status

This repository is being professionalized from multiple Rork/AI-generated prototypes into one maintainable SwiftUI product.

Non-canonical prototypes should be archived after their product ideas are documented. Do not create new duplicate repositories for experiments.

## Tech Stack

- iOS native: SwiftUI
- Persistence: SwiftData
- Backend sync: Supabase
- AI companion: NathIA through Supabase Edge Function proxy
- Subscriptions: RevenueCat iOS SDK
- Tooling: Xcode, Swift Testing, SwiftLint, GitHub Actions

## Repository Layout

```text
ios/NossaMaternidade/        App source
ios/NossaMaternidadeTests/   Unit tests
ios/NossaMaternidadeUITests/ UI tests
ios/Config/                  Local build configuration examples
scripts/                     Build and quality scripts
supabase/                    Database schema and future migrations
docs/                        Architecture, decisions, consolidation notes
```

## Local Setup

Requirements:

- macOS with Xcode installed
- iOS Simulator runtime compatible with the project
- SwiftLint for local linting
- GitHub CLI optional, but recommended

Clone:

```bash
git clone https://github.com/gabrielvesz11-ship-it/NossaMaternidadeTeste.git
cd NossaMaternidadeTeste
```

Create local config:

```bash
cp ios/Config/Secrets.xcconfig.example ios/Config/Secrets.local.xcconfig
```

Fill only local or development values. Never commit `Secrets.local.xcconfig`.

Build for simulator:

```bash
scripts/build-simulator.sh
```

Run the local quality check:

```bash
scripts/quality-check.sh
```

## Configuration

Config values are read from Xcode build settings, app Info.plist values, or environment variables.

Development keys:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
NATHIA_PROXY_URL=
REVENUECAT_API_KEY=
REVENUECAT_OFFERING_ID=default
REVENUECAT_ENTITLEMENT_ID=premium
REVENUECAT_YEARLY_PRODUCT_ID=
SUPABASE_PHOTO_BUCKET=journal-photos
TERMS_URL=https://nossamaternidade.com.br/termos
PRIVACY_URL=https://nossamaternidade.com.br/privacidade
```

Production rule: `ANTHROPIC_API_KEY` must not ship inside the mobile app. Set it only as a Supabase Edge Function secret for `supabase/functions/nath-ai`.

## Development Workflow

1. Create or link an issue.
2. Create a branch from `main`.
3. Keep changes scoped and reviewable.
4. Run `scripts/quality-check.sh`.
5. Open a pull request.
6. Merge only after CI passes and review is approved.

No direct pushes to `main`.

## Testing

Run Xcode tests:

```bash
xcodebuild test \
  -project ios/NossaMaternidade.xcodeproj \
  -scheme NossaMaternidade \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  CODE_SIGNING_ALLOWED=NO
```

Current testing priorities:

- Config loading and missing-config behavior.
- Pregnancy/date calculations.
- SwiftData model defaults.
- Supabase request/error mapping with mocked network boundaries.
- NathIA empty/error states.
- Paywall entitlement states.

## Security

- Do not commit secrets.
- Do not log tokens, API keys, auth responses, or user health/pregnancy data.
- Database changes require review.
- Never run production migrations from local scripts.

Report security concerns using `SECURITY.md`.

## License

Proprietary. All rights reserved unless the business explicitly decides otherwise.
