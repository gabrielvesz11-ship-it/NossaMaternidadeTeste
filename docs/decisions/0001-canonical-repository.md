# ADR 0001: Canonical Repository

## Status

Accepted.

## Context

The `gabrielvesz11-ship-it` account contains many generated repositories with overlapping Nossa Maternidade, Nathalia, MamaVida, and Lion app experiments. This makes the product look unfocused and makes engineering work harder to review, test, and maintain.

## Decision

Use `NossaMaternidadeTeste` as the only canonical codebase for the Nossa Maternidade product family. Rename it to `NossaMaternidade` after the old duplicate repository is archived or renamed.

Archive non-canonical repositories after useful product ideas are recorded.

## Consequences

Positive:

- One source of truth.
- Faster onboarding.
- CI and branch protection can be enforced in one place.
- Product decisions become visible through issues and ADRs instead of scattered clones.

Negative:

- Some prototype code becomes less visible after archiving.
- Renaming requires remote URL updates.

Mitigation:

- Keep GitHub redirects.
- Record consolidation notes in `docs/consolidation/audit-2026-05.md`.
- Migrate product concepts as issues before archiving.
