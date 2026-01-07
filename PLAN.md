# RepLedger — plan.md

## 0) Product snapshot

**Name:** RepLedger
**Category:** Premium strength training tracker (consumer-first) with an optional Coach add-on (seat-based, unlimited clients).
**Platforms (v1):** iOS (iPhone) — iPad + Mac support deferred to post-v1.
**No AI (for now).**
**Core promise:** During training, you can instantly see your previous performance per exercise (last session / last sets) so you always know what to beat next time.

### Non-negotiables
- Do **not** copy Strong (or any other app) branding, UI layouts, icons, wording, or assets.
- **Logging must never be blocked** by paywalls.
- Premium polish: fast, minimal clutter, excellent typography, great empty states, haptics, accessibility.
- Offline-first local persistence; accounts/sync architected but not required to use the app.

---

## 1) Goals & success criteria

### v1 goals
- Best-in-class workout logging UX: fast, one-handed, clear "last time" hints, effortless templates.
- Subscription paywalls implemented cleanly with StoreKit 2 entitlements (Free / Pro / Coach).
- Modern neon green theme with token-based design system.

### v1 "done means"
- App compiles and runs on iPhone.
- User can:
  - create templates (free up to 3)
  - start a workout from template or empty workout
  - add exercises, add sets, complete sets
  - see last-time hints per exercise
  - view workout history and exercise history
  - see PRs and basic trends
- Paywalls:
  - Trigger on template #4 creation (Pro)
  - Trigger on Pro-only analytics + export + backup toggle
  - Coach tab gated by Coach entitlement
- App Store submission requirements met.

---

## 2) MVP scope (v1)

### Core user flows
1) **Onboarding**
   - Enter name (optional, for personalized greeting)
   - Choose lifting units: kg / lb
   - Choose bodyweight display: kg / lb / stone+lb
   - Rest timer defaults (seconds) + auto-start toggle

2) **Templates**
   - Create / edit / duplicate / reorder templates
   - Free limit: 3 templates
   - Attempt to create template #4 → Pro paywall

3) **Start workout**
   - Quick Start (empty workout)
   - Start from template
   - Workout editor: exercises as cards; sets in rows
   - Add exercise: search + recent + favourites (optional favourites v1)
   - Add set + duplicate set + delete set
   - Complete set toggle
   - **Previous-set hints**: "Last time: 80kg x 8 (2 days ago)" + optionally last set list

4) **Rest timer**
   - Auto-start after completing a set (configurable)
   - Floating timer pill: pause/resume, +15s, dismiss
   - (Optional v1): local notifications only if user enables

5) **History**
   - Timeline grouped by week/month with collapsible sections
   - Rich workout cards with muscle tags, PR badges, stats
   - Advanced filtering (date range, muscle groups, templates)
   - Workout detail view: exercise list + sets + notes + stats

6) **Exercises**
   - Library seeded (50+ items) with muscle group + equipment
   - Exercise detail:
     - About (minimal original content)
     - History (workouts where performed + sets)
     - Records (PRs)
     - Charts (some gated by Pro)

7) **Dashboard**
   - Personalized greeting with user name
   - Weekly stats card (volume + sessions goal progress)
   - Last workout summary card
   - Recovery card (muscle groups)
   - Latest PR highlight card

8) **Settings**
   - Units (kg/lb + stone display)
   - Weekly goal (3-7 workouts)
   - Rest timer defaults
   - Template management
   - Export (Pro)
   - Backup/sync toggle (Pro stub in v1)
   - Restore purchases

---

## 3) Coach add-on (seat-based) — v1 scope

**Coach is a paid subscription per coach account ("seat"). Unlimited clients (no hard cap).**

### v1 Coach implementation philosophy
Ship **architecture + UI skeleton**, not full backend.
- A **Coach tab** exists but only appears if `isCoach == true`.
- Coach screens in v1:
  - Client list (empty state + preview data for testing)
  - Client detail (placeholder)
  - Invite client (disabled with "Coming soon")
  - Assign template (disabled with "Coming soon")
- Data models should anticipate coach/client sharing without requiring it in v1.

### Why this approach
- Keeps v1 shippable and consumer-first.
- Ensures we don't block the core tracker while still baking in the correct structure for v2.

---

## 4) Monetisation plan (StoreKit 2)

### Products (subscriptions only; no lifetime)
- `repledger_pro_monthly` ($4.99)
- `repledger_pro_annual` ($39.99)
- `repledger_coach_monthly` ($19.99)
- `repledger_coach_annual` ($149.99)

### Entitlements
- `isPro`: Pro subscription active
- `isCoach`: Coach subscription active (Coach implies Pro)

### Feature gates
- Free: up to **3 templates**
- Pro unlocks:
  - Unlimited templates
  - Advanced charts/insights
  - Export (CSV/PDF)
  - Backup/sync toggle (functional later)
- Coach unlocks:
  - Coach tab + (later) client system
  - Unlimited clients per seat (no coded limit)

### Paywall triggers
- Create template #4 → Pro paywall
- Tap Pro-only insights → blurred preview + Pro paywall
- Attempt to access Coach tab without entitlement → Coach paywall
- Soft upsell after 3 completed workouts (dismissible)

---

## 5) Design system & themes

### Design tokens
Implemented via `Theme` protocol:
- colors (background, surface, elevated, text, accent, accentGold, accentOrange, success, warning, divider)
- typography (title, body, caption weights/sizes)
- spacing scale (xs/sm/md/lg/xl/xxl)
- corner radii (small/medium/large/full)
- shadows (subtle/medium/prominent/neonGlow/card)
- header tokens (button sizes, typography, pill dimensions)

### Reusable components (all UI built from these)
- `RLCard`
- `RLButton`
- `RLPill`
- `RLStatTile`
- `RLInput`
- `RLSectionHeader`
- `RLEmptyState`
- `HeaderActionButton`
- `HeaderActionPill`

### Dashboard components
- `DashboardHeaderView` - Avatar + time-based greeting
- `DashboardStatsCard` - Weekly volume + goal progress
- `LastWorkoutCard` - Recent workout summary
- `RecoveryCard` - Muscle recovery progress bars
- `LatestPRCard` - Latest PR highlight
- `WeeklyVolumeChart` - Mini bar chart
- `GoalProgressRing` - Circular progress indicator

### Workout Detail components
- `WorkoutDetailHeader` - Title, date, duration, action menu
- `WorkoutDetailStatsCard` - Volume, sets, PRs, exercises stats
- `WorkoutDetailNotesCard` - Workout notes display
- `WorkoutDetailExerciseCard` - Expandable exercise with sets table
- `PRHighlightsCard` - Gold-styled PR highlights list

### Active theme: Neon Green (Obsidian)
```
accent: #00FF66 (neon green)
accentSecondary: #00CC52 (pressed)
accentGold: #FFD700 (PRs)
accentOrange: #FF9F43 (warnings)
background: #121212
surface: #1E1E1E
elevated: #2C2C2E
inputBackground: #0A0F0C
```

---

## 6) Architecture & code structure

### Targets
- iOS 17+ (iPhone only for v1)
- iPadOS 17+ (post-v1)
- macOS via Mac Catalyst (post-v1)

### File counts (96 Swift files total)
- App/: 2 files
- Models/: 9 files
- Services/: 5 files
- UIComponents/: 17 files
- Features/: 63 files

### Folder structure
- `App/` (entry point, routing, dependency container)
- `Models/` (SwiftData models, enums)
- `Services/`
  - `PersistenceService`
  - `MetricsService` (@ModelActor)
  - `PurchaseManager` (StoreKit 2 + entitlements)
  - `UserSettings` (UserDefaults wrapper)
  - `WorkoutManager` (active workout state + timer)
- `UIComponents/` (design system)
- `Features/`
  - `Onboarding/`
  - `Dashboard/`
  - `Start/`
  - `Workout/`
  - `History/` (+ WorkoutDetail/ + Models/)
  - `Exercises/`
  - `Paywall/`
  - `Coach/`
  - `Templates/`

### State management
- MVVM with `@Observable`
- Feature-level views, shared services injected via environment
- MetricsService uses `@ModelActor` for thread-safe SwiftData access

---

## 7) Data model (SwiftData)

### Entities
- `Exercise`
  - `id`, `name`, `muscleGroup`, `equipment`, `notes`, `isCustom`, `createdAt`
- `Template`
  - `id`, `name`, `orderedExerciseIds` (store as array), `createdAt`, `lastUsedAt`
- `Workout`
  - `id`, `title`, `startedAt`, `endedAt`, `notes`, `templateId?`
  - Computed: `duration`, `totalVolume`, `completedSetCount`, `liveDuration`
- `WorkoutExercise`
  - `id`, `workoutId`, `exerciseId`, `orderIndex`, `notes`
  - Computed: `totalVolume`, `bestSet`
- `SetEntry`
  - `id`, `workoutExerciseId`, `orderIndex`, `weight`, `reps`, `isCompleted`,
    `rpe?`, `setType?`, `createdAt`
  - Computed: `estimated1RM` (Epley), `volume`

### Unit strategy
- Internally store weights in kilograms (`Double`).
- Convert for display based on settings (lb and stone+lb for bodyweight display).
- e1RM uses Epley formula: `weight × (1 + reps/30)`

---

## 8) Metrics & "previous set hints"

### Metrics calculations
- Volume: `weight * reps` (handle bodyweight or nil weight gracefully)
- e1RM: Epley formula: `weight × (1 + reps/30)`
- PR detection:
  - max weight
  - max e1RM
  - max volume (per set)

### PR types
- `maxWeight` → "MAX LOAD"
- `maxE1RM` → "MAX 1RM"
- `maxVolume` → "MAX SET VOL"

### Previous set hints
For a given `Exercise` in an active workout:
- Find most recent prior workout containing that exercise
- Display:
  - "Last time: {date}"
  - "Best set: {weight} x {reps}"
  - Optional: list of last session sets as subtle ghost rows

---

## 9) Milestones & implementation order

### Milestone 1 — Foundation ✅ COMPLETE
- Xcode project + targets
- Theme system + core components
- SwiftData models + persistence service
- Seed exercise library (50+ exercises)
- 5-screen onboarding

### Milestone 2 — Logging MVP ✅ COMPLETE
- Templates CRUD + free limit logic
- Start workout (empty + from template)
- Workout editor (exercise cards, set rows, complete toggle)
- Rest timer pill with auto-start

### Milestone 3 — History + Exercise detail ✅ COMPLETE
- History timeline with month grouping
- Workout detail view
- Exercise library with search
- Exercise detail tabs (About/History/Records/Charts)
- MetricsService with O(N) PR detection

### Milestone 4 — Pro polish + Paywalls ✅ COMPLETE
- PurchaseManager with StoreKit 2
- Paywall screens (Pro + Coach)
- Feature gating (template #4, charts, export)
- Soft upsell after 3 workouts

### Milestone 5 — Coach skeleton ✅ COMPLETE
- Coach tab with client list
- Client detail view
- Empty state with feature cards
- "Coming soon" interactions

### Dashboard Redesign ✅ COMPLETE
- New neon green theme (#00FF66)
- Rich dashboard with stats, recovery, PRs
- Personalized greeting
- Real data wiring (not mock)

### Workout Editor Redesign ✅ COMPLETE
- New header with pulsing timer
- Grid-based set layout (5 columns)
- Visual set states (completed/active/pending)
- Drag to reorder exercises
- Floating add exercise button

### History Tab Redesign ✅ COMPLETE
- Inline search with animation
- Stats pills row
- Filter chips (All/Week/Month/PRs/Templates)
- Collapsible sections
- Rich workout cards with PR badges
- Advanced filter sheet

### Bug Fixes Applied ✅
- PR ID collision fix (unique per PR type)
- PR badge label consistency

---

## 10) App Store Submission Checklist

### 🔴 CRITICAL BLOCKERS (Must fix before submission)

| Item | Status | Action Required |
|------|--------|-----------------|
| **App Icon** | ✅ DONE | Added 1024x1024 PNG to AppIcon.appiconset |
| **Privacy Manifest** | ❌ MISSING | Create PrivacyInfo.xcprivacy file |
| **UIRequiredDeviceCapabilities** | ⚠️ Outdated | Remove `armv7` (deprecated 32-bit) |

### 🟡 Code & Configuration

| Item | Status | Notes |
|------|--------|-------|
| Build passes | ✅ Ready | iPhone simulator builds successfully |
| Bundle ID | ✅ Set | com.repledger.app |
| Version | ✅ Set | 1.0.0 (Build 1) |
| iOS Deployment | ✅ Set | iOS 17.0 |
| Entitlements | ✅ Ready | App Sandbox + Network Client |
| Encryption | ✅ Declared | ITSAppUsesNonExemptEncryption = false |
| Launch Screen | ✅ Ready | SwiftUI default (UILaunchScreen = {}) |
| Code Signing | ⚠️ Needs Team | Set DEVELOPMENT_TEAM in project.yml |

### 🟡 StoreKit Configuration

| Item | Status | Notes |
|------|--------|-------|
| Product IDs in code | ✅ Ready | 4 products defined in ProductID enum |
| PurchaseManager | ✅ Ready | Full StoreKit 2 implementation |
| .storekit file | ❌ Not created | Create via Xcode for testing (not needed for submission) |
| App Store Connect | ⏳ Pending | Must create products in ASC |

### 🟡 App Store Connect (External)

| Item | Status | Action Required |
|------|--------|-----------------|
| App Store Connect account | ⏳ Pending | Enroll in Apple Developer Program ($99/yr) |
| App listing created | ⏳ Pending | Create in ASC with bundle ID |
| In-App Purchases created | ⏳ Pending | Create 4 subscription products |
| Subscription group | ⏳ Pending | Create "RepLedger" group with Pro + Coach tiers |
| App description | ⏳ Pending | Write compelling description |
| Keywords | ⏳ Pending | Research ASO keywords |
| Screenshots | ⏳ Pending | 6.5" and 5.5" sizes minimum |
| App preview video | ⏳ Optional | 15-30 second demo video |
| Privacy policy URL | ⏳ Pending | Host privacy policy page |
| Support URL | ⏳ Pending | Host support page or use email |
| Age rating | ⏳ Pending | Complete questionnaire (likely 4+) |
| Contact info | ⏳ Pending | Review contact email + phone |

### 🟢 Features Complete

| Feature | Status |
|---------|--------|
| Onboarding | ✅ 5-screen flow |
| Dashboard | ✅ Rich stats + cards |
| Templates | ✅ CRUD + 3 free limit |
| Workout Logging | ✅ Full editor |
| Rest Timer | ✅ Auto-start + controls |
| History | ✅ Filtering + search |
| Workout Detail | ✅ Stats + PRs |
| Exercise Library | ✅ 50+ exercises |
| Exercise Detail | ✅ 4 tabs |
| Paywalls | ✅ Pro + Coach |
| Coach UI | ✅ Skeleton ready |
| Settings | ✅ All options |

---

## 11) Remaining Tasks for App Store Submission

### Phase 1: Critical Fixes (1-2 hours)

#### 1. Add App Icon
Create 1024x1024 PNG app icon and add to:
`RepLedger/Resources/Assets.xcassets/AppIcon.appiconset/`

Update Contents.json with filename reference.

#### 2. Create Privacy Manifest
Create `PrivacyInfo.xcprivacy` declaring:
- **NSPrivacyAccessedAPITypes**: UserDefaults (C617.1)
- **NSPrivacyCollectedDataTypes**: None (offline-first, no analytics)
- **NSPrivacyTrackingDomains**: Empty array

#### 3. Update Info.plist
Remove deprecated `armv7` from UIRequiredDeviceCapabilities or update to `arm64`.

#### 4. Set Development Team
In project.yml, set `DEVELOPMENT_TEAM` to your team ID for signing.

### Phase 2: Testing & Polish (2-4 hours)

#### 5. Create StoreKit Configuration File
Via Xcode: File > New > StoreKit Configuration
- Add subscription group "RepLedger"
- Add 4 products with correct IDs and prices
- Configure scheme to use for testing

#### 6. Manual Testing Checklist
- [ ] Onboarding completes and persists
- [ ] Quick Start workout creates correctly
- [ ] Template workout creates correctly
- [ ] Sets can be added, completed, deleted
- [ ] Rest timer auto-starts and controls work
- [ ] Workout finishes and appears in History
- [ ] History filtering works
- [ ] Workout detail shows correct stats/PRs
- [ ] Exercise detail tabs work
- [ ] Template #4 triggers Pro paywall
- [ ] Settings persist after app restart
- [ ] App recovers from background/kill

#### 7. Device Testing
Test on physical iPhone (not just simulator) for:
- Performance
- Haptics
- Keyboard behavior
- Safe area handling

### Phase 3: App Store Connect Setup (2-4 hours)

#### 8. Create App in App Store Connect
- Bundle ID: com.repledger.app
- Primary language: English
- Category: Health & Fitness

#### 9. Create In-App Purchases
Subscription group: "RepLedger"
| Product ID | Type | Price | Duration |
|------------|------|-------|----------|
| repledger_pro_monthly | Auto-renewable | $4.99 | 1 month |
| repledger_pro_annual | Auto-renewable | $39.99 | 1 year |
| repledger_coach_monthly | Auto-renewable | $19.99 | 1 month |
| repledger_coach_annual | Auto-renewable | $149.99 | 1 year |

#### 10. Write Marketing Copy
- App name: RepLedger
- Subtitle: "Strength Training Log"
- Description: 4000 chars max, highlight key features
- Keywords: 100 chars max, comma-separated
- What's New: Version 1.0 release notes

#### 11. Capture Screenshots
Required sizes:
- 6.5" (iPhone 15 Pro Max): 1290 x 2796
- 5.5" (iPhone 8 Plus): 1242 x 2208

Recommended screens:
1. Dashboard overview
2. Workout in progress
3. History view
4. Exercise detail
5. PR celebration

#### 12. Legal Pages
- Privacy Policy (required)
- Terms of Service (recommended)
- Support page or email

### Phase 4: Build & Submit (1-2 hours)

#### 13. Archive Build
```bash
xcodebuild -scheme RepLedger \
  -destination "generic/platform=iOS" \
  -archivePath ./build/RepLedger.xcarchive \
  archive
```

#### 14. Upload to App Store Connect
- Via Xcode Organizer or `altool`
- Wait for processing

#### 15. Complete App Review Information
- Demo account (if needed): N/A (offline app)
- Notes for reviewer: Explain subscription tiers
- Contact info for review team

#### 16. Submit for Review
- Choose manual or automatic release
- Submit and wait (typically 24-48 hours)

---

## 12) Technical Debt & Future Improvements

### Code Organization
- [ ] Extract DashboardView, ExerciseLibraryView, SettingsView from ContentView.swift
- [ ] Remove unused theme files (StudioTheme, ForgeTheme) or complete them
- [ ] Clean up empty folders (Utilities, SyncEngine)

### Testing (Milestone 6)
- [ ] Unit tests for MetricsService (PR detection, volume calc)
- [ ] Unit tests for unit conversion (kg/lb/stone)
- [ ] Unit tests for template gating logic
- [ ] UI tests for critical flows

### Accessibility
- [ ] VoiceOver audit on all screens
- [ ] Dynamic Type testing (especially workout editor)
- [ ] Color contrast verification

### Performance
- [ ] Profile with Instruments (Core Data, SwiftUI)
- [ ] Verify no memory leaks in workout flow
- [ ] Test with 100+ workouts in history

---

## 13) Post-v1 Roadmap

### v1.1 — Polish & Fixes
- Bug fixes from user feedback
- Performance optimizations
- Accessibility improvements

### v1.5 — Pro backup/sync + accounts
- Sign in with Apple
- Cloud backup/sync (CloudKit)
- Multi-device sync for Pro users
- Data export (CSV/PDF)

### v2 — Coach real features
- Client invites + acceptance
- Client sharing permissions
- Coach assigns templates to clients
- Compliance views + progress summaries

### v3 — Web dashboard (coach-first)
- Program builder + scheduling
- Staff management
- Exports, reporting, client notes
- Stripe billing (optional)

---

## 14) Constraints & principles

- Consumer-first always: never let Coach complexity bloat the core logging experience.
- Paywalls must feel premium and fair; never block logging.
- Ship fast, then expand: Coach backend and web dashboard only after v1 validates retention and conversion.
- iPhone-first for v1: iPad/Mac support deferred to ensure quality on primary platform.
