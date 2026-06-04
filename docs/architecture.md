# Architecture

Nossa Maternidade is an iOS-first SwiftUI app. The canonical codebase should stay focused on a single production app instead of preserving generated prototypes.

## Boundaries

- `Core`: shared platform code such as configuration, service composition, navigation, networking, persistence, design primitives, and utilities.
- `Features`: user-facing flows. Feature code may use `Core` and `Models`, but should not depend directly on another feature.
- `Models`: shared SwiftData and domain models.
- `Resources`: app assets and static resources.
- `supabase`: schema and future migration files. Production migrations require explicit human approval.

## Data Flow

SwiftUI views should delegate external work to services through injectable seams. Services own network/API/SDK boundaries. SwiftData remains the local source for app state that must survive app restarts.

## Configuration

Configuration must come from Xcode build settings, Info.plist values, environment variables, or local ignored `.xcconfig` files. Real secrets must not be committed.

The Anthropic API key is not safe in a production mobile binary. NathIA production traffic must move behind a backend or Supabase Edge Function.

## Quality Bar

- No direct pushes to `main`.
- CI must build, test, and lint pull requests.
- SwiftLint must block force unwraps, force casts, force tries, and oversized files.
- Tests must cover core logic and service failure modes before broad feature work.
