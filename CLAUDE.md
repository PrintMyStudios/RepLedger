# RepLedger — Claude Code Memory (CLAUDE.md)

See @plan.md for the full product spec/roadmap and @README.md for repository overview.

## What you are building
- RepLedger is an original, premium strength training tracker for iPhone + iPad + Mac (Mac Catalyst preferred).
- Consumer-first. “Coach” is a paid add-on (seat-based subscription) with **unlimited clients** (no hard cap in code).
- No AI features in v1.

## Non‑negotiable rules
- Do **not** copy any competitor app’s UI layouts, text, icons, assets, or branding. All UI and copy must be original.
- **Never block workout logging** with paywalls. Paywalls can gate templates/insights/export/coach tools only.
- Keep v1 shippable: Coach backend + web dashboard are **not** in scope for v1 (UI + architecture stubs only).

## How to work in this repo (workflow)
- Prefer small, verifiable steps:
  - Make a plan for each change → implement → run/build → sanity-check UI on iPhone + iPad + Mac.
- When unsure, choose the simplest correct implementation and leave clean TODOs for later phases.
- Update docs when you discover new “project truths” (commands, gotchas, conventions).

## Build / test expectations (macOS)
- Always discover available schemes before assuming names:
  - `xcodebuild -list`
- Build (example):
  - `xcodebuild -scheme RepLedger -destination "platform=iOS Simulator,name=iPhone 15" build`
- Prefer targeted checks over “run everything” if builds are slow.

## Key product rules (StoreKit 2)
Product IDs must match exactly:
- `repledger_pro_monthly`
- `repledger_pro_annual`
- `repledger_coach_monthly`  (coach seat)
- `repledger_coach_annual`   (coach seat)

Entitlements:
- `isPro` → Pro features
- `isCoach` → Coach workspace visibility

Gating:
- Free users: **max 3 templates**. Attempt to create template #4 → Pro paywall.
- Pro: unlimited templates + advanced insights + export + backup toggle (backup/sync may be stubbed in v1).
- Coach: Coach tab + coach screens (v1 placeholder), **unlimited clients** per seat.

## Data + units
- Offline-first persistence (SwiftData).
- Store weights in a canonical unit internally (kg recommended) and convert for display:
  - Lifting units: kg / lb
  - Bodyweight display: kg / lb / stone+lb

## UI / design system requirements
- Implement a real theme system with 3 presets:
  - Obsidian (premium dark)
  - Studio (clean light)
  - Forge (bold athletic)
- All screens must use shared components (e.g., RLCard/RLButton/RLInput/RLPill/RLStatTile) so theme switching is global.

## Coach v1 scope (placeholder only)
- Coach tab appears only when `isCoach == true`.
- Coach screens in v1 are UI + architecture stubs:
  - Client list (empty state)
  - Client detail (placeholder)
  - Invite client / Assign template: disabled with “Coming soon”
- No real invite/sharing backend in v1.

## Testing requirements (unit tests)
Add/maintain tests for:
- volume calculation
- e1RM calculation
- PR detection
- template gating (3 free → 4th triggers paywall)
- unit conversion + stone+lb formatting edge cases

## Keeping memory clean
- Keep this file concise and bullet-based.
- If this file grows large, move detailed rules into `.claude/rules/*.md` (topic-based) and keep this as a high-level index.
