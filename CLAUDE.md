# RepLedger — Claude Code Memory (CLAUDE.md)

See @plan.md for the full product spec/roadmap and @README.md for repository overview.

## What you are building
- RepLedger is an original, premium strength training tracker for iPhone + iPad + Mac (Mac Catalyst preferred).
- Consumer-first. "Coach" is a paid add-on (seat-based subscription) with **unlimited clients** (no hard cap in code).
- No AI features in v1.

## Current status
- **Milestone 1 (Foundation)**: COMPLETE
- **Milestone 2 (Logging MVP)**: Not started

## Non‑negotiable rules
- Do **not** copy any competitor app's UI layouts, text, icons, assets, or branding. All UI and copy must be original.
- **Never block workout logging** with paywalls. Paywalls can gate templates/insights/export/coach tools only.
- Keep v1 shippable: Coach backend + web dashboard are **not** in scope for v1 (UI + architecture stubs only).

## How to work in this repo (workflow)
- Prefer small, verifiable steps:
  - Make a plan for each change → implement → run/build → sanity-check UI on iPhone + iPad + Mac.
- When unsure, choose the simplest correct implementation and leave clean TODOs for later phases.
- Update docs when you discover new "project truths" (commands, gotchas, conventions).
- Project uses **xcodegen** for Xcode project generation. Run `xcodegen generate` after adding new files.

## Build / test commands
```bash
# Regenerate Xcode project (after adding files)
xcodegen generate

# List schemes
xcodebuild -list

# Build for iPhone
xcodebuild -scheme RepLedger -destination "platform=iOS Simulator,name=iPhone 16" build

# Build for iPad
xcodebuild -scheme RepLedger -destination "platform=iOS Simulator,name=iPad Pro 13-inch (M4)" build

# Build for Mac Catalyst
xcodebuild -scheme RepLedger -destination "platform=macOS,variant=Mac Catalyst" build
```

## Key file locations

### App Entry
- `RepLedger/App/RepLedgerApp.swift` - Main app, ModelContainer setup, ThemeManager injection
- `RepLedger/App/ContentView.swift` - Root view, onboarding check, tab shell

### Theme System
- `RepLedger/UIComponents/Theme/Theme.swift` - Protocol + design tokens
- `RepLedger/UIComponents/Theme/ThemeManager.swift` - @Observable, persists to UserDefaults
- `RepLedger/UIComponents/Theme/ObsidianTheme.swift` - Premium dark (amber accent)
- `RepLedger/UIComponents/Theme/StudioTheme.swift` - Clean light (blue-gray accent)
- `RepLedger/UIComponents/Theme/ForgeTheme.swift` - Bold athletic (red-orange accent)

### Core UI Components
- `RepLedger/UIComponents/RLCard.swift`
- `RepLedger/UIComponents/RLButton.swift`
- `RepLedger/UIComponents/RLInput.swift`
- `RepLedger/UIComponents/RLPill.swift`
- `RepLedger/UIComponents/RLStatTile.swift`
- `RepLedger/UIComponents/RLSectionHeader.swift`
- `RepLedger/UIComponents/RLEmptyState.swift`

### SwiftData Models
- `RepLedger/Models/Exercise.swift` - Seeded exercise library
- `RepLedger/Models/Template.swift` - Workout templates (3 free limit)
- `RepLedger/Models/Workout.swift` - Workout sessions
- `RepLedger/Models/WorkoutExercise.swift` - Exercise in workout
- `RepLedger/Models/SetEntry.swift` - Individual set with e1RM calc

### Enums
- `RepLedger/Models/Enums/MuscleGroup.swift` - 12 muscle groups
- `RepLedger/Models/Enums/Equipment.swift` - 8 equipment types
- `RepLedger/Models/Enums/SetType.swift` - warmup/working/dropset/failure
- `RepLedger/Models/Enums/WeightUnit.swift` - kg/lb + bodyweight stone+lb

### Services
- `RepLedger/Services/PersistenceService.swift` - Exercise seeding, fetch helpers
- `RepLedger/Services/UserSettings.swift` - @Observable, UserDefaults wrapper

### Features
- `RepLedger/Features/Onboarding/OnboardingView.swift` - 5-screen onboarding

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
- Store weights in **kilograms internally** (`Double`) and convert for display:
  - Lifting units: kg / lb
  - Bodyweight display: kg / lb / stone+lb
- e1RM uses Epley formula: `weight × (1 + reps/30)`

## UI / design system requirements
- Theme system with 3 presets: Obsidian (dark), Studio (light), Forge (dark athletic)
- All screens use shared components (RLCard/RLButton/RLInput/RLPill/RLStatTile/RLSectionHeader/RLEmptyState)
- Color scheme switches automatically based on theme (Obsidian/Forge = dark, Studio = light)

## User settings (UserDefaults keys)
- `hasCompletedOnboarding` (Bool)
- `liftingUnit` (kg/lb)
- `bodyweightUnit` (kg/lb/stoneLb)
- `restTimerDuration` (Int, default 90 seconds)
- `restTimerAutoStart` (Bool, default true)
- `selectedTheme` (obsidian/studio/forge)

## Coach v1 scope (placeholder only)
- Coach tab appears only when `isCoach == true`.
- Coach screens in v1 are UI + architecture stubs:
  - Client list (empty state)
  - Client detail (placeholder)
  - Invite client / Assign template: disabled with "Coming soon"
- No real invite/sharing backend in v1.

## Testing requirements (unit tests)
Add/maintain tests for:
- volume calculation
- e1RM calculation (Epley: weight × (1 + reps/30))
- PR detection
- template gating (3 free → 4th triggers paywall)
- unit conversion + stone+lb formatting edge cases

## Gotchas discovered
- Use `.tint` not `.accent` for foreground style (`.accent` doesn't exist)
- ThemeID needs `Identifiable` conformance for ForEach
- xcodegen requires iOS platform only for Mac Catalyst (set `SUPPORTS_MACCATALYST: true`)
- Info.plist warning about CFBundlePackageType is cosmetic, can ignore

## Keeping memory clean
- Keep this file concise and bullet-based.
- If this file grows large, move detailed rules into `.claude/rules/*.md` (topic-based) and keep this as a high-level index.
