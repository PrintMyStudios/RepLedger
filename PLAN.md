# RepLedger — plan.md

## 0) Product snapshot

**Name:** RepLedger  
**Category:** Premium strength training tracker (consumer-first) with an optional Coach add-on (seat-based, unlimited clients).  
**Platforms (v1):** iOS (iPhone) + iPadOS + macOS (Mac Catalyst preferred).  
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
- Best-in-class workout logging UX: fast, one-handed, clear “last time” hints, effortless templates.
- Multi-platform polish: iPad + Mac keyboard shortcuts and pointer-friendly UI.
- Subscription paywalls implemented cleanly with StoreKit 2 entitlements (Free / Pro / Coach).
- 3 theme presets shipped (Obsidian / Studio / Forge) with real token-based design system.

### v1 “done means”
- App compiles and runs on iPhone, iPad, and Mac Catalyst.
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
- Unit tests cover: volume calc, e1RM calc, PR detection, template gating.

---

## 2) MVP scope (v1)

### Core user flows
1) **Onboarding**
   - Choose lifting units: kg / lb
   - Choose bodyweight display: kg / lb / stone+lb
   - Choose theme: Obsidian / Studio / Forge
   - Optional: rest timer defaults (seconds) + auto-start toggle

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
   - **Previous-set hints**: “Last time: 80kg x 8 (2 days ago)” + optionally last set list

4) **Rest timer**
   - Auto-start after completing a set (configurable)
   - Floating timer pill: pause/resume, +15s, dismiss
   - (Optional v1): local notifications only if user enables

5) **History**
   - Timeline grouped by month
   - Workout detail view: exercise list + sets + notes + stats
   - Search workouts by exercise name

6) **Exercises**
   - Library seeded (30–60 items) with muscle group + equipment
   - Exercise detail:
     - About (minimal original content)
     - History (workouts where performed + sets)
     - Records (PRs)
     - Charts (some gated by Pro)

7) **Insights**
   - Free: basic charts (e.g., last 30 days)
   - Pro: all-time charts + filters + muscle group volume breakdown (Phase 1: simplest useful set)

8) **Settings**
   - Units (kg/lb + stone display)
   - Theme selector (3 presets)
   - Rest timer defaults
   - Export (Pro)
   - Backup/sync toggle (Pro stub in v1)
   - Restore purchases

---

## 3) Coach add-on (seat-based) — v1 scope

**Coach is a paid subscription per coach account (“seat”). Unlimited clients (no hard cap).**

### v1 Coach implementation philosophy
Ship **architecture + UI skeleton**, not full backend.
- A **Coach tab** exists but only appears if `isCoach == true`.
- Coach screens in v1:
  - Client list (empty state)
  - Client detail (placeholder)
  - Invite client (disabled with “Coming soon”)
  - Assign template (disabled with “Coming soon”)
- Data models should anticipate coach/client sharing without requiring it in v1.

### Why this approach
- Keeps v1 shippable and consumer-first.
- Ensures we don’t block the core tracker while still baking in the correct structure for v2.

---

## 4) Monetisation plan (StoreKit 2)

### Products (subscriptions only; no lifetime)
- `repledger_pro_monthly`
- `repledger_pro_annual`
- `repledger_coach_monthly`
- `repledger_coach_annual`

### Entitlements
- `isPro`: Pro subscription active
- `isCoach`: Coach subscription active

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

## 5) Design system & themes (must be real)

### Design tokens
Implement a central `Theme` model:
- colors (background, surface, elevated, text, accent, success, warning, divider)
- typography (title, body, caption weights/sizes)
- spacing scale
- corner radii
- shadows
- chart style preferences (line thickness, grid visibility)

### Reusable components (all UI built from these)
- `RLCard`
- `RLButton`
- `RLPill`
- `RLStatTile`
- `RLInput`
- `RLSectionHeader`
- `RLEmptyState`

### Theme presets
- **Obsidian:** premium dark, subtle gradients, minimal chrome
- **Studio:** clean light, editorial spacing, quiet accents
- **Forge:** bold athletic, higher contrast, punchy accents

---

## 6) Architecture & code structure

### Targets
- iOS 17+
- iPadOS 17+
- macOS via Mac Catalyst (minimum macOS version aligned with Xcode defaults)

### Folder structure
- `App/` (entry point, routing, dependency container)
- `Models/` (SwiftData models, enums)
- `Services/`
  - `PersistenceService`
  - `MetricsService`
  - `EntitlementsService`
  - `PurchaseManager` (StoreKit 2)
  - `AccountManager` (stub, Sign in with Apple placeholder)
  - `SyncEngine/` (`SyncEngine` protocol + `LocalOnlySyncEngine` + `RemoteSyncEngine` stub)
- `UIComponents/` (design system)
- `Features/`
  - `Onboarding/`
  - `Dashboard/`
  - `Start/`
  - `Workout/`
  - `History/`
  - `Exercises/`
  - `Insights/`
  - `Coach/`
  - `Settings/`
- `Utilities/` (formatters, unit conversions)

### State management
- MVVM with `Observable` / `@Observable` or `ObservableObject` (consistent approach)
- Feature-level view models, shared services injected via environment/dependency container

---

## 7) Data model (SwiftData)

### Entities
- `Exercise`
  - `id`, `name`, `muscleGroup`, `equipment`, `notes`, `isCustom`, `createdAt`
- `Template`
  - `id`, `name`, `orderedExerciseIds` (store as array), `createdAt`, `lastUsedAt`
- `Workout`
  - `id`, `title`, `startedAt`, `endedAt`, `notes`, `templateId?`
- `WorkoutExercise`
  - `id`, `workoutId`, `exerciseId`, `orderIndex`, `notes`
- `SetEntry`
  - `id`, `workoutExerciseId`, `orderIndex`, `weight`, `reps`, `isCompleted`,
    `rpe?`, `tempo?`, `setType?`, `createdAt`
- (Optional v1) `MeasurementEntry`
  - `id`, `type`, `value`, `unit`, `date`

### Unit strategy
- Internally store weights in a canonical unit (e.g., kilograms as `Double`).
- Convert for display based on settings (lb and stone+lb for bodyweight display).
- Ensure rounding rules are sensible (e.g., 2.5kg plates; optional later).

---

## 8) Metrics & “previous set hints”

### Metrics calculations
- Volume: `weight * reps` (handle bodyweight or nil weight gracefully)
- e1RM: choose formula (e.g., Epley) and document it
- PR detection:
  - max weight
  - max e1RM
  - max volume (per set or per workout, decide and document)

### Previous set hints
For a given `Exercise` in an active workout:
- Find most recent prior workout containing that exercise
- Display:
  - “Last time: {date}”
  - “Best set: {weight} x {reps}”
  - Optional: list of last session sets as subtle ghost rows

---

## 9) Milestones & implementation order

### Milestone 1 — Foundation (Day 1–2)
- Xcode project + targets for iOS/iPad/Mac
- Theme system + core components
- SwiftData models + persistence service
- Seed exercise library

**Acceptance**
- App launches, onboarding sets units/theme, shows empty dashboard.

### Milestone 2 — Logging MVP (Day 3–5)
- Templates CRUD + free limit logic
- Start workout (empty + from template)
- Workout editor (exercise cards, set rows, complete toggle)
- Rest timer pill

**Acceptance**
- User can fully log workouts and save history.

### Milestone 3 — History + Exercise detail (Day 6–7)
- History timeline
- Workout detail
- Exercise list + search + filters
- Exercise detail tabs: About/History/Records/Charts (charts basic)

**Acceptance**
- User can review and learn from past workouts quickly.

### Milestone 4 — Pro polish + Paywalls (Day 8–9)
- StoreKit 2 purchase manager
- Entitlements service
- Paywall screens (Pro + Coach)
- Gating:
  - template #4
  - pro charts/insights
  - export + backup toggle
- Soft upsell after 3 workouts

**Acceptance**
- Purchases mocked in dev; gates work; logging never blocked.

### Milestone 5 — Coach skeleton (Day 10)
- Coach tab appears only if `isCoach`
- Placeholder coach screens (client list empty state, disabled invite/assign)

**Acceptance**
- Coach upgrade feels real without backend.

### Milestone 6 — Tests + stability (Day 11–12)
- Unit tests for metrics, PR detection, gating
- Edge cases: delete exercises, empty workouts, missing weights, unit conversion
- Accessibility pass

**Acceptance**
- No crashes in basic flows; tests pass.

---

## 10) QA checklist (pre-release)

### Functional
- Onboarding works; settings persist
- Template gating: free=3, pro=unlimited
- Workout editor: add/remove exercises/sets; save/resume
- Previous set hints correct and fast
- History accurate; exercise history correct
- Pro gates correct; coach gates correct
- Restore purchases works (at least in StoreKit config)

### UX/polish
- Empty states tasteful and helpful
- Haptics are subtle, not spammy
- Scrolling is smooth; no jank with SwiftData fetches
- iPad/Mac keyboard shortcuts work for core actions

### Accessibility
- Dynamic Type readable
- VoiceOver labels on interactive controls
- Adequate contrast in all 3 themes

---

## 11) Roadmap (post-v1)

### v1.5 — Pro backup/sync + accounts
- Sign in with Apple (real)
- Cloud backup/sync (CloudKit or chosen backend)
- Multi-device sync for Pro users
- Data export improvements

### v2 — Coach real features
- Client invites + acceptance
- Client sharing permissions
- Coach assigns templates/programs to clients
- Compliance views + progress summaries

### v3 — Web dashboard (coach-first)
- Program builder + scheduling
- Staff management (true “seat management”)
- Exports, reporting, client notes
- Stripe org billing (optional) if gyms request central payment

---

## 12) Constraints & principles

- Consumer-first always: never let Coach complexity bloat the core logging experience.
- Paywalls must feel premium and fair; never block logging.
- Ship fast, then expand: Coach backend and web dashboard only after v1 validates retention and conversion.
