# RepLedger — Claude Code Memory (CLAUDE.md)

See @plan.md for the full product spec/roadmap and @README.md for repository overview.

## What you are building
- RepLedger is an original, premium strength training tracker for **iPhone only** (v1 focus).
- iPad + Mac support deferred to post-v1 refactor.
- Consumer-first. "Coach" is a paid add-on (seat-based subscription) with **unlimited clients** (no hard cap in code).
- No AI features in v1.

## Current status
- **Milestone 1 (Foundation)**: COMPLETE
- **Milestone 2 (Logging MVP)**: COMPLETE
- **Milestone 3 (History + Exercise detail)**: COMPLETE
- **Milestone 4 (Pro polish + Paywalls)**: COMPLETE
- **Milestone 5 (Coach skeleton)**: COMPLETE
- **Dashboard Redesign**: COMPLETE (Phase 1 - Static mockup)
- **Workout Editor Redesign**: COMPLETE
- **History Tab Redesign**: COMPLETE
- **Milestone 6 (Tests + stability)**: NOT STARTED ← **NEXT**

---

## COMPLETED: Dashboard Redesign (Phase 1)

### What was built
- **New Neon Green Theme**: Single theme with #00FF66 accent, replacing multi-theme system
- **Rich Dashboard**: Header with greeting, stats cards, last workout, recovery, and PR display
- **Personalized Greeting**: Time-based greeting with user name from onboarding
- **Static Mock Data**: Dashboard displays placeholder data (real data wiring in Phase 2)

### Key files added
- `RepLedger/Features/Dashboard/DashboardHeaderView.swift` - Avatar + time-based greeting + action buttons
- `RepLedger/Features/Dashboard/DashboardStatsCard.swift` - Weekly volume + goal progress split card
- `RepLedger/Features/Dashboard/LastWorkoutCard.swift` - Recent workout summary
- `RepLedger/Features/Dashboard/RecoveryCard.swift` - Muscle recovery progress bars
- `RepLedger/Features/Dashboard/LatestPRCard.swift` - Latest PR highlight with gold accent
- `RepLedger/Features/Dashboard/WeeklyVolumeChart.swift` - Mini bar chart component
- `RepLedger/Features/Dashboard/GoalProgressRing.swift` - Circular progress indicator

### Key files modified
- `RepLedger/UIComponents/Theme/Theme.swift` - Added accentGold, accentOrange, neonGlow shadow, card shadow
- `RepLedger/UIComponents/Theme/ObsidianTheme.swift` - Updated to neon green palette (#00FF66)
- `RepLedger/UIComponents/Theme/StudioTheme.swift` - Added new color properties (unused)
- `RepLedger/UIComponents/Theme/ForgeTheme.swift` - Added new color properties (unused)
- `RepLedger/Services/UserSettings.swift` - Added userName property
- `RepLedger/Features/Onboarding/OnboardingView.swift` - Replaced theme page with name input, reordered flow
- `RepLedger/App/ContentView.swift` - New DashboardView layout, removed theme picker from Settings

### Architecture decisions
- **Single theme**: Removed theme picker, using neon green Obsidian as only theme
- **Static mock data first**: Dashboard shows placeholder values, real data wiring deferred
- **userName in onboarding**: Optional name input replaces theme selection
- **Neon glow shadow**: Added to ThemeShadows for CTA button effects

### Design tokens (Neon Theme - Obsidian)
```
// Backgrounds
background: #121212
surface: #1E1E1E
elevated: #2C2C2E
inputBackground: #0A0F0C
surfaceDeep: #0A0A0C

// Text
text: #FFFFFF
textSecondary: #A1A1AA
textTertiary: #6B7280
textOnAccent: #121212 (dark text on neon green)

// Accent
accent: #00FF66 (neon green)
accentSecondary: #00CC52 (hover/pressed)
accentGold: #FFD700 (PRs, achievements)
accentOrange: #FF9F43 (warnings, partial progress)

// Semantic
success: #00FF66 (matches accent)
warning: #FF9F43
error: #FF453A

// Borders
divider: #3A3A3C
border: #3A3A3C

// Special
completedSetTint: #15261D (green-tinted for completed sets)
```

### Onboarding flow (updated)
1. Welcome → 2. Name Input → 3. Lifting Units → 4. Bodyweight → 5. Rest Timer

---

## COMPLETED: Workout Editor Redesign

### What was built
- **New Header Design**: Centered layout with live timer (pulsing dot), editable title via alert, pill-style Finish button
- **Redesigned Exercise Cards**: Grid-based layout with muscle tags, drag handle, 5-column set rows
- **Visual Set States**: Completed (green left border + tinted bg), Active (larger inputs), Pending (60% opacity)
- **Floating Add Exercise Button**: Full-width pill at bottom with gradient fade and glow shadow
- **Drag to Reorder**: Full drag-drop reordering of exercises within workout
- **Previous Performance Column**: Shows "220 x 5" format in dedicated column, or "—" if no data

### Key files added
- `RepLedger/Features/Workout/WorkoutHeaderView.swift` - Centered header with pulsing timer, title editing

### Key files modified
- `RepLedger/UIComponents/Theme/Theme.swift` - Added `inputBackground` color token
- `RepLedger/UIComponents/Theme/ObsidianTheme.swift` - Added `inputBackground: #0A0F0C`
- `RepLedger/Features/Workout/WorkoutEditorView.swift` - New header, floating button, drag-drop layout
- `RepLedger/Features/Workout/ExerciseCardView.swift` - Grid layout, muscle tags, drag handle
- `RepLedger/Features/Workout/SetRowView.swift` - 5-column grid with visual states
- `RepLedger/Services/WorkoutManager.swift` - Added `updateWorkoutTitle()` method
- `RepLedger/Models/Workout.swift` - Added `liveDuration` computed property (HH:MM:SS format)

### Architecture decisions
- **SetVisualState enum**: `.completed`, `.active`, `.pending` for clear set styling
- **Grid-based set layout**: 5 columns - Set | Previous | Weight | Reps | Check
- **String-based drag-drop**: UUID.uuidString used for Transferable conformance
- **Refactored view structure**: Complex views broken into sub-functions for Swift type-checker

### Set row visual states
| State | Left Border | Background | Badge | Inputs | Check |
|-------|-------------|------------|-------|--------|-------|
| Completed | 4px green | accent 5% | Green | Filled values | Green filled |
| Active | None | Clear | White | Larger (48h) | Empty bordered |
| Pending | None | Clear 60% | Dim | Smaller (40h) | Dim bordered |

### Design tokens (new)
```
inputBackground: #0A0F0C (dark, green-tinted for inputs)
```

### Build passes
- iPhone (v1 target)

---

## COMPLETED: History Tab Redesign

### What was built
- **Rich Header**: Large "History" title + workout count, pill container with Search + Filter buttons
- **Inline Search**: Animated transition from header to search bar, cancel to dismiss
- **Stats Pills Row**: Horizontal scroll with This Week sessions, Volume with trend percentage, Time
- **Filter Chips Row**: All, Week, Month, PRs (gold badge), Templates with selection state
- **Collapsible Sections**: "THIS WEEK", "LAST WEEK", month groupings with animated chevron
- **Rich Workout Cards**: Muscle tag, PR badge (green/gold), top set highlight, stats grid
- **Template Modification Detection**: "Modified" badge when workout differs from original template
- **Advanced Filter Sheet**: Date range, muscle groups, templates, PRs only toggle
- **End of History Marker**: Decorative end indicator with total workout count

### Key files added
- `RepLedger/Features/History/Models/HistoryFilterState.swift` - Filter state, section types, section groups
- `RepLedger/Features/History/HistoryHeaderView.swift` - Header with inline search mode
- `RepLedger/Features/History/HistoryStatsPillsView.swift` - Weekly stats horizontal scroll
- `RepLedger/Features/History/HistoryFilterChipsView.swift` - Filter chip selection
- `RepLedger/Features/History/HistoryFilterSheet.swift` - Advanced filter modal with FlowLayout
- `RepLedger/Features/History/CollapsibleSectionHeader.swift` - Animated section header
- `RepLedger/Features/History/HistoryWorkoutCard.swift` - Rich workout card component
- `RepLedger/Features/History/HistoryEndMarker.swift` - End of timeline indicator

### Key files modified
- `RepLedger/Features/History/HistoryView.swift` - Complete rewrite with new components
- `RepLedger/Models/Workout.swift` - Added `totalVolume`, `topSet`, `wasModifiedFromTemplate()`
- `RepLedger/Services/MetricsService.swift` - Added `getWeeklyStats()`, `getSectionStats()`

### Architecture decisions
- **HistoryFilterState @Observable**: Centralized filter state with section collapse tracking
- **HistorySectionType enum**: `.thisWeek`, `.lastWeek`, `.month(year:month:)` for smart grouping
- **Lazy PR loading**: PR count loaded per-card via task to avoid blocking scroll
- **FlowLayout**: Custom Layout for filter chips (muscle groups, templates)
- **Native search animation**: Custom inline search replaces `.searchable` for design control

### Section grouping logic
- "THIS WEEK": Workouts from start of current week to now
- "LAST WEEK": Workouts from start of previous week to start of current week
- Month sections: All older workouts grouped by month (e.g., "OCTOBER 2025")

### Card visual states
| PR Count | Border | Badge Color | Glow |
|----------|--------|-------------|------|
| 0 | Gray | None | None |
| 1-2 | Green tint | Green | Subtle radial |
| 3+ | Green tint | Gold | Prominent radial |

### Filter options
- **Time Period**: All, Week, Month, PRs Only, Templates
- **Advanced**: Date range picker, muscle group multi-select, template multi-select
- **Active indicator**: Green dot on filter button when filters active

### Build passes
- iPhone (v1 target)

---

## Bug Fixes Applied

### PR Display Bug (WorkoutSetPR ID Collision)
**Issue**: When completing one set of an exercise, 3 PRs were detected (maxWeight, maxE1RM, maxVolume) but all displayed as "MAX LOAD" in the PR Highlights card.

**Root Cause**: `WorkoutSetPR.id` was set to `setId`, so all PRs for the same set shared the same ID. SwiftUI's `ForEach` rendered duplicate data when encountering duplicate IDs.

**Fix**: Changed `WorkoutSetPR.id` from a stored `UUID` to a computed property combining `setId` and `prType`:
```swift
// Before:
let id: UUID  // = setId (same for all PRs on same set)

// After:
var id: String { "\(setId.uuidString)-\(prType.rawValue)" }  // Unique per PR type
```

**Files modified**:
- `RepLedger/Services/MetricsService.swift` - WorkoutSetPR.id now computed property

### PR Badge Labels Update
**Issue**: PR badges showed inconsistent labels ("EST 1RM", "SET VOL" vs "MAX LOAD").

**Fix**: Unified all PR badge labels to use "MAX" prefix:
- `maxWeight` → "MAX LOAD"
- `maxE1RM` → "MAX 1RM"
- `maxVolume` → "MAX SET VOL" (was "SET VOL")

**Files modified**:
- `RepLedger/Services/MetricsService.swift` - PRType.badgeText and titleText
- `RepLedger/Features/History/WorkoutDetail/WorkoutDetailExerciseCard.swift` - Uses PRType.badgeText instead of hardcoded strings

---

## NEXT: Milestone 6 — Tests + stability

### What to build
- Unit tests for metrics, PR detection, gating
- Edge cases: delete exercises, empty workouts, missing weights, unit conversion
- Accessibility pass

### Acceptance criteria
- No crashes in basic flows
- Tests pass

### After Milestone 6
Ask user for approval before v1 release preparation.

---

## COMPLETED: Milestone 5 — Coach skeleton

### What was built
- **Client Model**: `CoachClientPresentable` protocol + `ClientSummary` struct for v2-ready architecture
- **Rich Empty State**: `CoachEmptyStateView` with "How Coach Works" and "Why Coach?" cards
- **Client List**: Full client list with search (`.searchable`), sort menu, NavigationSplitView for iPad/Mac
- **Client Detail**: `ClientDetailView` with avatar, stats, templates section, activity section
- **Coming Soon UX**: `ComingSoonSheet` shown once, `ComingSoonButton` with pill badge

### Key files added
- `RepLedger/Features/Coach/ClientSummary.swift` - CoachClientPresentable protocol + ClientSummary model
- `RepLedger/Features/Coach/CoachClientPreviewData.swift` - DEBUG-only sample data
- `RepLedger/Features/Coach/ClientRowView.swift` - Client list row with avatar, stats, active indicator
- `RepLedger/Features/Coach/ClientDetailView.swift` - Full client detail screen
- `RepLedger/Features/Coach/CoachEmptyStateView.swift` - Rich empty state with feature cards
- `RepLedger/Features/Coach/ComingSoonSheet.swift` - Shared "Coming Soon" sheet + ComingSoonButton

### Key files modified
- `RepLedger/Features/Coach/CoachView.swift` - Full client list with NavigationSplitView (iPad/Mac) and NavigationStack (iPhone)
- `RepLedger/Services/UserSettings.swift` - Added hasSeenCoachComingSoon, showCoachPreviewData (DEBUG)

### Architecture decisions
- **CoachClientPresentable protocol**: Views accept `any CoachClientPresentable` - real Client model will conform in v2
- **NavigationSplitView for iPad/Mac**: Uses `#if targetEnvironment(macCatalyst)` for reliable Mac handling
- **"Coming soon" buttons are tappable**: Not truly disabled - styled .secondary with pill, trigger sheet once
- **Native .searchable**: Integrates with nav bar for premium iOS feel
- **DEBUG preview toggle**: `showCoachPreviewData` in UserSettings for development testing

### Implementation notes
- Empty state by default in production - preview data requires DEBUG toggle
- Coach tab visibility still gated by `purchaseManager.isCoach` in ContentView
- All typography uses theme tokens (titleMedium, body, caption - not raw Font)
- Active indicator uses `theme.colors.success` with accessibility label
- DateFormatter used for join date and last active formatting
- All builds pass: iPhone, iPad, Mac Catalyst

---

## COMPLETED: Milestone 4 — Pro polish + Paywalls

### What was built
- **PurchaseManager**: Single source of truth for StoreKit 2 purchases and entitlements
- **Paywall Screens**: ProPaywallView, CoachPaywallView, ProUpsellSheet
- **Feature Gating**: Template #4, volume chart, export/backup in Settings
- **Coach Tab**: Visible only when isCoach == true

### Key files added
- `RepLedger/Services/PurchaseManager.swift` - StoreKit 2 with isPro/isCoach (Coach implies Pro)
- `RepLedger/Features/Paywall/PaywallFeatureRow.swift` - Reusable feature row component
- `RepLedger/Features/Paywall/ProPaywallView.swift` - Pro upgrade paywall
- `RepLedger/Features/Paywall/CoachPaywallView.swift` - Coach upgrade paywall
- `RepLedger/Features/Paywall/ProUpsellSheet.swift` - Soft upsell after 3 workouts
- `RepLedger/Features/Coach/CoachView.swift` - Coach tab placeholder

### Key files modified
- `RepLedger/Services/UserSettings.swift` - Added completedWorkoutCount, hasShownProUpsell
- `RepLedger/Services/WorkoutManager.swift` - Guarded workout count increment in finishWorkout()
- `RepLedger/App/RepLedgerApp.swift` - Inject PurchaseManager, start on launch
- `RepLedger/App/ContentView.swift` - Coach tab visibility, Settings Pro gates, soft upsell trigger
- `RepLedger/Features/Templates/TemplateListView.swift` - Template #4 paywall gate
- `RepLedger/Features/Exercises/ExerciseChartsTab.swift` - Volume chart Pro gate with unlock button

### Architecture decisions
- **Single subscription group "RepLedger"** with two levels: Pro and Coach (Coach is higher tier)
- **Coach implies Pro**: `isPro = isCoach || hasProProduct`
- **Consolidated EntitlementsService into PurchaseManager** - single source of truth
- **Soft upsell**: Triggers when completedWorkoutCount >= 3 AND !hasShownProUpsell AND !isPro

### Implementation notes
- PurchaseManager uses `@Observable` + `@MainActor` with `nonisolated init()` for EnvironmentKey
- Transaction listener runs for app lifetime via `Task.detached`
- ProChartGate has explicit "Unlock with Pro" button (avoids scroll interference from tap gesture)
- Workout count only increments for genuine completions (wasInProgress && hasCompletedSets)

### Remaining manual step
Create `RepLedger/StoreKit.storekit` via Xcode GUI:
- Single subscription group "RepLedger"
- Pro level: `repledger_pro_monthly` ($4.99), `repledger_pro_annual` ($39.99)
- Coach level: `repledger_coach_monthly` ($19.99), `repledger_coach_annual` ($149.99)
- Configure scheme to use StoreKit file for testing

---

## COMPLETED: Milestone 3 — History + Exercise Detail

### What was built
- **History Timeline**: HistoryView with workouts grouped by month, search by exercise name
- **Workout Detail**: WorkoutDetailView with exercise cards, sets table, PR badges, delete action
- **Exercise Detail**: ExerciseDetailView with 4 tabs (About/History/Records/Charts)
- **MetricsService**: @ModelActor for thread-safe PR detection and metrics

### Key files added
- `RepLedger/Services/MetricsService.swift` - @ModelActor with O(N) PR detection
- `RepLedger/Features/History/HistoryView.swift` - Month-grouped timeline with search
- `RepLedger/Features/History/WorkoutDetailView.swift` - Full workout detail
- `RepLedger/Features/History/WorkoutHistoryCard.swift` - Workout card component
- `RepLedger/Features/History/WorkoutSummaryStats.swift` - Stats grid component
- `RepLedger/Features/Exercises/ExerciseDetailView.swift` - Tabbed container
- `RepLedger/Features/Exercises/ExerciseAboutTab.swift` - Muscle group, equipment, notes
- `RepLedger/Features/Exercises/ExerciseHistoryTab.swift` - Workout history for exercise
- `RepLedger/Features/Exercises/ExerciseRecordsTab.swift` - Personal records display
- `RepLedger/Features/Exercises/ExerciseChartsTab.swift` - Swift Charts with Pro gating

### Implementation notes
- MetricsService uses `@ModelActor` for thread-safe SwiftData access
- PR detection is O(N) with precomputed `priorBest` map
- Month grouping uses `DateComponents` with `MonthKey` struct (not string formatting)
- Volume trends chart is blurred with Pro gate (ready for M4 wiring)
- ExerciseLibraryView updated with NavigationLink to ExerciseDetailView

---

## COMPLETED: Milestone 2 — Logging MVP

### What was built
- **Templates CRUD**: TemplateListView, TemplateEditorView, TemplateRowView
- **Start Workout**: Quick Start and From Template flows
- **Workout Editor**: WorkoutEditorView, ExerciseCardView, SetRowView, ExercisePickerView
- **Rest Timer**: RestTimerView floating overlay with +15s, pause/resume, auto-start
- **WorkoutManager**: Service managing active workout state and timer

### Key files added
- `RepLedger/Services/WorkoutManager.swift` - Workout state + rest timer (@Observable)
- `RepLedger/Features/Templates/*` - Template CRUD views
- `RepLedger/Features/Workout/*` - Workout editor views
- `RepLedger/Features/Start/TemplatePickerView.swift` - Template selection

---

## Non‑negotiable rules
- Do **not** copy any competitor app's UI layouts, text, icons, assets, or branding. All UI and copy must be original.
- **Never block workout logging** with paywalls. Paywalls can gate templates/insights/export/coach tools only.
- Keep v1 shippable: Coach backend + web dashboard are **not** in scope for v1 (UI + architecture stubs only).

---

## Design System Compliance (CRITICAL)

**All UI must use theme tokens. Never use hardcoded colors.**

### Color Rules
1. **NEVER use hardcoded hex colors** like `Color(hex: "121212")` outside theme definitions
2. **NEVER use system colors** like `.white`, `.black`, `.gray` for UI elements
3. **ALWAYS use theme tokens** via `theme.colors.xxx` for all colors

### Available Theme Tokens
```swift
// Backgrounds
theme.colors.background      // Main app background (#121212)
theme.colors.surface         // Card/container surfaces (#1E1E1E)
theme.colors.elevated        // Elevated elements like sheets (#2C2C2E)
theme.colors.inputBackground // Input field backgrounds (#0A0F0C)
theme.colors.surfaceDeep     // Deepest layer for modals/previews (#0A0A0C)

// Text
theme.colors.text            // Primary text (#FFFFFF)
theme.colors.textSecondary   // Secondary/muted text (#A1A1AA)
theme.colors.textTertiary    // Hint/disabled text (#6B7280)
theme.colors.textOnAccent    // Text on accent backgrounds (#121212 for Obsidian)

// Accent & Semantic
theme.colors.accent          // Primary accent (#00FF66 neon green)
theme.colors.accentSecondary // Pressed/hover state (#00CC52)
theme.colors.accentGold      // PRs, achievements (#FFD700)
theme.colors.accentOrange    // Warnings, partial progress (#FF9F43)
theme.colors.success         // Success states (matches accent)
theme.colors.warning         // Warning states (#FF9F43)
theme.colors.error           // Error/destructive (#FF453A)

// Borders & Dividers
theme.colors.divider         // Divider lines (#3A3A3C)
theme.colors.border          // Border strokes (#3A3A3C)

// Special
theme.colors.overlay         // Modal overlays (black 60%)
theme.colors.completedSetTint // Completed set background (#15261D)
```

### Common Patterns
```swift
// ✅ CORRECT - Text on accent button
.foregroundStyle(theme.colors.textOnAccent)
.background(theme.colors.accent)

// ❌ WRONG - Hardcoded colors
.foregroundStyle(.black)
.background(Color(hex: "00FF66"))

// ✅ CORRECT - Preview backgrounds
#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        // content
    }
    .environment(ThemeManager())
}

// ❌ WRONG - Hardcoded preview background
#Preview {
    ZStack {
        Color(hex: "121212").ignoresSafeArea()
        // content
    }
}

// ✅ CORRECT - Shadows use theme or .black.opacity()
.shadow(color: .black.opacity(0.3), radius: 10)
.rlShadow(theme.shadows.neonGlow)

// ✅ CORRECT - Borders use theme tokens
.stroke(theme.colors.border.opacity(0.5))

// ❌ WRONG - System gray for borders
.stroke(Color.gray.opacity(0.3))
```

### Exceptions (Allowed)
- `Color.clear` for transparent backgrounds
- `.black.opacity()` for shadows (matches theme shadow pattern)
- `.ultraThinMaterial` for blur effects
- System colors inside theme definition files only

### When Adding New Colors
1. Add token to `ThemeColors` struct in `Theme.swift`
2. Implement in all 3 themes: `ObsidianTheme`, `StudioTheme`, `ForgeTheme`
3. Use via `theme.colors.newToken` everywhere

---

## Header Token System (CRITICAL)

**All tab headers must use `theme.header.*` tokens. Never hardcode font sizes or button dimensions in headers.**

### Header Token Values
```swift
// Typography
theme.header.pageTitleFont       // 28pt bold - page titles ("History", "Start")
theme.header.greetingFont        // 13pt semibold - Dashboard greeting (uppercase)
theme.header.dashboardMessageFont // 22pt bold - Dashboard message ("Ready to crush it?")
theme.header.subtitleFont        // 14pt regular - subtitles ("42 workouts completed")

// Button Dimensions
theme.header.buttonVisualSize    // 40pt - visual button size
theme.header.buttonTapSize       // 44pt - tap target (Apple minimum)
theme.header.iconSize            // 16pt - SF Symbol icon size
theme.header.iconWeight          // .semibold - icon weight

// Pill Container
theme.header.pillHeight          // 44pt - action pill height
theme.header.pillPadding         // 6pt - horizontal padding inside pill
theme.header.pillButtonSpacing   // 0pt - spacing between buttons in pill
theme.header.pillDividerHeight   // 24pt - divider height between buttons
```

### Reusable Header Components
```swift
// Single action button (circle style)
HeaderActionButton(icon: "magnifyingglass", action: { })

// With badge
HeaderActionButton(icon: "bell.fill", action: { }, badge: .notification)
HeaderActionButton(icon: "line.3.horizontal.decrease", action: { }, badge: .activeFilter)

// Multiple buttons in pill container
HeaderActionPill {
    HeaderActionButton(icon: "bell.fill", action: { })
    HeaderActionButton(icon: "magnifyingglass", action: { })
}

// With divider between buttons
HeaderActionPill {
    HeaderActionButton(icon: "magnifyingglass", action: { })
    HeaderPillDivider()
    HeaderActionButton(icon: "line.3.horizontal.decrease", action: { })
}
```

### Header Files
- `RepLedger/UIComponents/Theme/Theme.swift` - `ThemeHeaderTokens` struct definition
- `RepLedger/UIComponents/HeaderActionButton.swift` - Reusable button with 44pt tap target
- `RepLedger/UIComponents/HeaderActionPill.swift` - Pill container + `HeaderPillDivider`
- `RepLedger/Features/Dashboard/DashboardHeaderView.swift` - Uses greeting + message fonts
- `RepLedger/Features/History/HistoryHeaderView.swift` - Uses page title + subtitle fonts
- `RepLedger/Features/Start/StartHeaderView.swift` - Uses page title + subtitle fonts

### Header Patterns
```swift
// ✅ CORRECT - Use tokens for header typography
Text("History")
    .font(theme.header.pageTitleFont)

Text("42 workouts completed")
    .font(theme.header.subtitleFont)

// ❌ WRONG - Hardcoded sizes in headers
Text("History")
    .font(.system(size: 28, weight: .bold))

// ✅ CORRECT - Use HeaderActionButton for action buttons
HeaderActionButton(icon: "magnifyingglass", action: { })

// ❌ WRONG - Custom button implementations with hardcoded sizes
Button { } label: {
    Image(systemName: "magnifyingglass")
        .font(.system(size: 16))
        .frame(width: 40, height: 40)
}

// ✅ CORRECT - Dashboard greeting with proper tokens
Text(greetingText)
    .font(theme.header.greetingFont)
    .tracking(1.0)
    .textCase(.uppercase)

Text("Ready to crush it?")
    .font(theme.header.dashboardMessageFont)
    .lineLimit(2)
    .minimumScaleFactor(0.9)
```

---

## How to work in this repo (workflow)
- Prefer small, verifiable steps:
  - Make a plan for each change → implement → run/build → sanity-check UI on iPhone.
- When unsure, choose the simplest correct implementation and leave clean TODOs for later phases.
- Update docs when you discover new "project truths" (commands, gotchas, conventions).
- Project uses **xcodegen** for Xcode project generation. Run `xcodegen generate` after adding new files.
- **v1 is iPhone only** - iPad/Mac support deferred to post-v1.

## Build / test commands
```bash
# Regenerate Xcode project (after adding files)
xcodegen generate

# Build for iPhone (v1 target)
xcodebuild -scheme RepLedger -destination "platform=iOS Simulator,name=iPhone 16" build
```

## Key file locations

### App Entry
- `RepLedger/App/RepLedgerApp.swift` - Main app, ModelContainer setup, ThemeManager injection
- `RepLedger/App/ContentView.swift` - Root view, onboarding check, tab shell, StartWorkoutView

### Theme System
- `RepLedger/UIComponents/Theme/Theme.swift` - Protocol + design tokens (colors, typography, spacing, shadows, **header tokens**)
- `RepLedger/UIComponents/Theme/ThemeManager.swift` - @Observable, persists to UserDefaults
- `RepLedger/UIComponents/Theme/ObsidianTheme.swift` - Neon green dark theme (#00FF66 accent) ← **ACTIVE THEME**
- `RepLedger/UIComponents/Theme/StudioTheme.swift` - Clean light (unused, kept for future)
- `RepLedger/UIComponents/Theme/ForgeTheme.swift` - Bold athletic (unused, kept for future)

### Core UI Components
- `RepLedger/UIComponents/RLCard.swift`
- `RepLedger/UIComponents/RLButton.swift`
- `RepLedger/UIComponents/RLInput.swift`
- `RepLedger/UIComponents/RLPill.swift`
- `RepLedger/UIComponents/RLStatTile.swift`
- `RepLedger/UIComponents/RLSectionHeader.swift`
- `RepLedger/UIComponents/RLEmptyState.swift`
- `RepLedger/UIComponents/HeaderActionButton.swift` - Reusable header button with 44pt tap target
- `RepLedger/UIComponents/HeaderActionPill.swift` - Pill container for multiple header buttons

### SwiftData Models
- `RepLedger/Models/Exercise.swift` - Seeded exercise library
- `RepLedger/Models/Template.swift` - Workout templates (3 free limit)
- `RepLedger/Models/Workout.swift` - Workout sessions (has `isInProgress`, `duration`, `completedSetCount`)
- `RepLedger/Models/WorkoutExercise.swift` - Exercise in workout (has `totalVolume`, `bestSet`)
- `RepLedger/Models/SetEntry.swift` - Individual set (has `estimated1RM`, `volume`)

### Enums
- `RepLedger/Models/Enums/MuscleGroup.swift` - 12 muscle groups
- `RepLedger/Models/Enums/Equipment.swift` - 8 equipment types
- `RepLedger/Models/Enums/SetType.swift` - warmup/working/dropset/failure
- `RepLedger/Models/Enums/WeightUnit.swift` - kg/lb + bodyweight stone+lb

### Services
- `RepLedger/Services/PersistenceService.swift` - Exercise seeding, fetch helpers, deleteWorkout
- `RepLedger/Services/UserSettings.swift` - @Observable, UserDefaults wrapper
- `RepLedger/Services/WorkoutManager.swift` - Active workout state, rest timer (@Observable)
- `RepLedger/Services/MetricsService.swift` - @ModelActor for PR detection and metrics
- `RepLedger/Services/PurchaseManager.swift` - StoreKit 2 purchases, isPro/isCoach entitlements (@Observable)

### Features (Dashboard Redesign)
- `RepLedger/Features/Dashboard/DashboardHeaderView.swift` - Avatar + greeting + action buttons
- `RepLedger/Features/Dashboard/DashboardStatsCard.swift` - Weekly volume + goal progress split card
- `RepLedger/Features/Dashboard/LastWorkoutCard.swift` - Recent workout summary
- `RepLedger/Features/Dashboard/RecoveryCard.swift` - Muscle recovery progress bars
- `RepLedger/Features/Dashboard/LatestPRCard.swift` - Latest PR highlight with gold accent
- `RepLedger/Features/Dashboard/WeeklyVolumeChart.swift` - Mini bar chart component
- `RepLedger/Features/Dashboard/GoalProgressRing.swift` - Circular progress indicator

### Features (Milestone 2)
- `RepLedger/Features/Onboarding/OnboardingView.swift` - 5-screen onboarding (Welcome → Name → Units → Bodyweight → Rest Timer)
- `RepLedger/Features/Templates/*` - TemplateListView, TemplateEditorView, TemplateRowView
- `RepLedger/Features/Workout/*` - WorkoutEditorView, ExerciseCardView, SetRowView, ExercisePickerView, RestTimerView
- `RepLedger/Features/Start/TemplatePickerView.swift` - Template selection sheet

### Features (History - Redesigned)
- `RepLedger/Features/History/HistoryView.swift` - Main view with filtering, sections, rich cards
- `RepLedger/Features/History/Models/HistoryFilterState.swift` - Filter state, section types
- `RepLedger/Features/History/HistoryHeaderView.swift` - Header with inline search
- `RepLedger/Features/History/HistoryStatsPillsView.swift` - Weekly stats pills
- `RepLedger/Features/History/HistoryFilterChipsView.swift` - Filter chip row
- `RepLedger/Features/History/HistoryFilterSheet.swift` - Advanced filter modal
- `RepLedger/Features/History/CollapsibleSectionHeader.swift` - Animated section header
- `RepLedger/Features/History/HistoryWorkoutCard.swift` - Rich workout card
- `RepLedger/Features/History/HistoryEndMarker.swift` - End of timeline marker
- `RepLedger/Features/History/WorkoutDetailView.swift` - Workout detail screen
- `RepLedger/Features/History/WorkoutHistoryCard.swift` - Legacy card (kept for reference)
- `RepLedger/Features/History/WorkoutSummaryStats.swift` - Stats grid component

### Features (Workout Detail)
- `RepLedger/Features/History/WorkoutDetail/WorkoutDetailHeader.swift` - Header with title, date, action menu
- `RepLedger/Features/History/WorkoutDetail/WorkoutDetailStatsCard.swift` - Volume, sets, PRs, exercises, duration stats
- `RepLedger/Features/History/WorkoutDetail/WorkoutDetailNotesCard.swift` - Workout notes display
- `RepLedger/Features/History/WorkoutDetail/WorkoutDetailExerciseCard.swift` - Expandable exercise with sets table, PR badges
- `RepLedger/Features/History/WorkoutDetail/PRHighlightsCard.swift` - PR highlights with gold styling

### Features (Exercises)
- `RepLedger/Features/Exercises/*` - ExerciseDetailView, ExerciseAboutTab, ExerciseHistoryTab, ExerciseRecordsTab, ExerciseChartsTab

### Features (Milestone 4)
- `RepLedger/Features/Paywall/PaywallFeatureRow.swift` - Reusable feature row for paywalls
- `RepLedger/Features/Paywall/ProPaywallView.swift` - Pro upgrade paywall screen
- `RepLedger/Features/Paywall/CoachPaywallView.swift` - Coach upgrade paywall screen
- `RepLedger/Features/Paywall/ProUpsellSheet.swift` - Soft upsell after 3 workouts

### Features (Milestone 5)
- `RepLedger/Features/Coach/CoachView.swift` - Client list with NavigationSplitView (iPad/Mac)
- `RepLedger/Features/Coach/ClientSummary.swift` - CoachClientPresentable protocol + ClientSummary model
- `RepLedger/Features/Coach/ClientRowView.swift` - Client row with avatar, stats, active indicator
- `RepLedger/Features/Coach/ClientDetailView.swift` - Client detail screen
- `RepLedger/Features/Coach/CoachEmptyStateView.swift` - Rich empty state with feature cards
- `RepLedger/Features/Coach/ComingSoonSheet.swift` - Shared "Coming Soon" sheet + button
- `RepLedger/Features/Coach/CoachClientPreviewData.swift` - DEBUG-only sample data

## Data + units
- Offline-first persistence (SwiftData).
- Store weights in **kilograms internally** (`Double`) and convert for display:
  - Lifting units: kg / lb
  - Bodyweight display: kg / lb / stone+lb
- e1RM uses Epley formula: `weight × (1 + reps/30)`
- Volume = weight × reps (sum for workout/exercise totals)

## User settings (UserDefaults keys)
- `hasCompletedOnboarding` (Bool)
- `userName` (String, optional - for personalized greeting)
- `liftingUnit` (kg/lb)
- `bodyweightUnit` (kg/lb/stoneLb)
- `restTimerDuration` (Int, default 90 seconds)
- `restTimerAutoStart` (Bool, default true)
- `selectedTheme` (obsidian only - theme picker removed)
- `completedWorkoutCount` (Int, for soft upsell trigger)
- `hasShownProUpsell` (Bool, ensures upsell shows only once)

## Gotchas discovered
- Use `.tint` not `.accent` for foreground style (`.accent` doesn't exist)
- ThemeID needs `Identifiable` conformance for ForEach
- xcodegen requires iOS platform only for Mac Catalyst (set `SUPPORTS_MACCATALYST: true`)
- Info.plist warning about CFBundlePackageType is cosmetic, can ignore
- WorkoutManager needs `nonisolated init()` for EnvironmentKey default value
- Complex SwiftUI views may need body broken into computed properties to avoid type-check timeout
- MetricsService uses `@ModelActor` for thread-safe SwiftData access (not @MainActor)
- Month grouping should use `DateComponents` not string formatting for reliable ordering
- Cache DateFormatter at type level to avoid repeated creation
- StoreKit `Transaction` type is ambiguous - use `StoreKit.Transaction` explicitly in function signatures
- `@MainActor` services cannot cancel tasks in deinit (deinit is nonisolated) - avoid deinit for cleanup
- **SwiftUI ForEach duplicate IDs**: When multiple items share the same `Identifiable.id`, ForEach renders duplicate content from the first item. Ensure IDs are unique (e.g., combine multiple fields like `setId + prType`)

## Keeping memory clean
- Keep this file concise and bullet-based.
- If this file grows large, move detailed rules into `.claude/rules/*.md` (topic-based) and keep this as a high-level index.
