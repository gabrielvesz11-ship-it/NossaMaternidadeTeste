# Security Policy

## Supported Project

Only the canonical Nossa Maternidade repository is supported for security review and fixes.

Archived prototype repositories are not maintained and should not be used as production sources.

## Reporting a Vulnerability

Do not open a public issue for sensitive findings.

Report privately to the repository owner with:

- Affected area.
- Reproduction steps.
- Impact.
- Suggested fix, if known.

## Secret Handling

Never commit:

- API keys.
- Supabase service role keys.
- RevenueCat private credentials.
- Anthropic API keys.
- `.env` files.
- `Secrets.local.xcconfig`.

Development config must come from `ios/Config/Secrets.local.xcconfig`, Xcode build settings, environment variables, or GitHub Actions secrets.

Production NathIA requests must not use an Anthropic key embedded in the iOS app. Use a backend or Supabase Edge Function.

## Data Handling

Pregnancy, diary, chat, subscription, and profile data are sensitive product data. Do not log raw payloads, tokens, or personally identifiable information.
