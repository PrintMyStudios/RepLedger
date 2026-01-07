# RepLedger

Premium strength training tracker for iPhone, iPad, and Mac — built for progressive overload.

RepLedger is a **consumer-first** lifting log with an optional **Coach** add‑on (seat-based, unlimited clients). The MVP is **offline-first**, fast, and beautifully designed with 3 built-in theme presets.

> Note: This project must not copy any existing app's UI, assets, copy, or branding. RepLedger is an original product in the strength-tracking category.

---

## Current Status

| Milestone | Status |
|-----------|--------|
| 1. Foundation | ✅ Complete |
| 2. Logging MVP | ✅ Complete |
| 3. History + Exercise detail | ✅ Complete |
| 4. Pro polish + Paywalls | Not started |
| 5. Coach skeleton | Not started |
| 6. Tests + stability | Not started |

---

## Features (MVP)

### Logging
- Quick Start (empty workout) or start from Template
- Exercises as cards + set rows
- One-tap set completion
- Swipe actions for sets (duplicate/delete)
- **Previous session hints** per exercise (last performed date + last/best sets)

### Templates
- Create / edit / duplicate / reorder templates
- **Free limit:** 3 templates
- Creating template #4 triggers Pro paywall

### History & Exercises
- Workout history timeline (grouped by month)
- Workout details with stats (duration, volume, PRs)
- Exercise library (50+ seeded exercises) + search/filter
- Exercise detail: About / History / Records / Charts (Charts partly gated)

### Rest timer
- Auto-start after set completion (configurable, default 90s)
- Floating timer pill (+15s, pause, dismiss)

### Insights (Charts)
- Free: basic (e.g., last 30 days)
- Pro: advanced, all-time trends, filters, muscle group volume breakdown

### Monetisation
Subscriptions (StoreKit 2), no lifetime:
- Pro: templates unlimited, advanced insights, export, backup toggle
- Coach: unlocks coach workspace (seat-based), unlimited clients per seat

---

## Platforms

- iOS 17+
- iPadOS 17+
- macOS 14+ via **Mac Catalyst**

---

## Setup

### Prerequisites
- Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Build & Run

```bash
# Generate Xcode project
xcodegen generate

# Open in Xcode
open RepLedger.xcodeproj

# Or build from command line
xcodebuild -scheme RepLedger -destination "platform=iOS Simulator,name=iPhone 16" build
```

### Targets
- **iOS Simulator**: iPhone 16, etc.
- **iPad Simulator**: iPad Pro 13-inch (M4), etc.
- **Mac Catalyst**: "My Mac (Mac Catalyst)"

### StoreKit testing (recommended during development)

Use a StoreKit Configuration file (`.storekit`) for local purchase testing:
1. In Xcode: **File → New → File… → StoreKit Configuration File**
2. Add products:
   - `repledger_pro_monthly` (auto-renewable subscription)
   - `repledger_pro_annual` (auto-renewable subscription)
   - `repledger_coach_monthly` (auto-renewable subscription)
   - `repledger_coach_annual` (auto-renewable subscription)
3. In the scheme: **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration**
4. Choose the `.storekit` file and run.

---

## Project Structure

```
RepLedger/
├── App/
│   ├── RepLedgerApp.swift      # Entry point, ModelContainer, ThemeManager
│   └── ContentView.swift        # Root view, onboarding, tab shell
├── Models/
│   ├── Exercise.swift           # Exercise library model
│   ├── Template.swift           # Workout templates (3 free limit)
│   ├── Workout.swift            # Workout sessions
│   ├── WorkoutExercise.swift    # Exercise in workout
│   ├── SetEntry.swift           # Individual set with e1RM
│   └── Enums/
│       ├── MuscleGroup.swift    # 12 muscle groups
│       ├── Equipment.swift      # 8 equipment types
│       ├── SetType.swift        # warmup/working/dropset/failure
│       └── WeightUnit.swift     # kg/lb + bodyweight stone+lb
├── Services/
│   ├── PersistenceService.swift # Exercise seeding, fetch helpers
│   ├── UserSettings.swift       # @Observable settings wrapper
│   └── WorkoutManager.swift     # Active workout state + rest timer
├── UIComponents/
│   ├── Theme/
│   │   ├── Theme.swift          # Protocol + design tokens
│   │   ├── ThemeManager.swift   # @Observable theme state
│   │   ├── ObsidianTheme.swift  # Premium dark
│   │   ├── StudioTheme.swift    # Clean light
│   │   └── ForgeTheme.swift     # Bold athletic
│   ├── RLCard.swift
│   ├── RLButton.swift
│   ├── RLInput.swift
│   ├── RLPill.swift
│   ├── RLStatTile.swift
│   ├── RLSectionHeader.swift
│   └── RLEmptyState.swift
├── Features/
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # 5-screen onboarding
│   ├── Dashboard/
│   ├── Start/
│   │   └── TemplatePickerView.swift # Template selection sheet
│   ├── Templates/
│   │   ├── TemplateListView.swift   # Templates list with CRUD
│   │   ├── TemplateEditorView.swift # Create/edit templates
│   │   └── TemplateRowView.swift    # Template row component
│   ├── Workout/
│   │   ├── WorkoutEditorView.swift  # Main workout logging screen
│   │   ├── ExerciseCardView.swift   # Exercise card with sets
│   │   ├── SetRowView.swift         # Weight/reps inputs
│   │   ├── ExercisePickerView.swift # Add exercise modal
│   │   └── RestTimerView.swift      # Floating timer overlay
│   ├── History/
│   ├── Exercises/
│   ├── Insights/
│   ├── Coach/
│   └── Settings/
├── Utilities/
├── Resources/
│   └── Assets.xcassets
├── Info.plist
└── RepLedger.entitlements
```

---

## Themes

RepLedger ships with 3 theme presets (selectable in Settings and Onboarding):

| Theme | Description | Color Scheme |
|-------|-------------|--------------|
| **Obsidian** | Premium dark, subtle gradients, amber accent | Dark |
| **Studio** | Clean editorial light, blue-gray accent | Light |
| **Forge** | Bold athletic contrast, red-orange accent | Dark |

All screens use reusable components (`RLCard`, `RLButton`, etc.) so theme switching is genuine and global.

---

## Architecture

- **SwiftUI + MVVM** with `@Observable`
- **SwiftData** persistence (offline-first)
- **Services:**
  - `PersistenceService` - Data access, exercise seeding
  - `UserSettings` - Preferences (@Observable)
  - `ThemeManager` - Theme state (@Observable)
  - `WorkoutManager` - Active workout state, rest timer (@Observable)
  - `MetricsService` - volume, e1RM, PR detection (TODO)
  - `PurchaseManager` - StoreKit 2 (TODO)
  - `EntitlementsService` - isPro / isCoach gating (TODO)

---

## Paywalls & gating rules

- Free: up to **3 templates**
- Pro:
  - Unlimited templates
  - Advanced charts/insights
  - Export (CSV/PDF)
  - Backup/sync toggle (functional later)
- Coach:
  - Coach workspace UI
  - Unlimited clients per coach seat (no cap in code)

Paywall triggers:
- Creating template #4 → Pro paywall
- Accessing advanced insights → Pro paywall
- Opening Coach tab without entitlement → Coach paywall

**Logging must never be blocked.**

---

## Roadmap

- **v1.5**: Sign in with Apple + cloud backup/sync (Pro)
- **v2**: Coach invites + client sharing + template assignment + compliance dashboards
- **v3**: Web dashboard (coach-first), plus gym/staff management

---

## Legal / content notes

- Do not use copyrighted exercise illustrations or copy text from other apps.
- Use original UI, icons (SF Symbols), and original exercise descriptions (kept minimal).
- If you add a program library later, ensure program names and marketing copy are original.

---

## License

TBD — choose a license before public distribution (e.g., proprietary, MIT, etc.).
