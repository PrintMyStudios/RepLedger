# RepLedger

Premium strength training tracker for iPhone, iPad, and Mac — built for progressive overload.

RepLedger is a **consumer-first** lifting log with an optional **Coach** add‑on (seat-based, unlimited clients). The MVP is **offline-first**, fast, and beautifully designed with 3 built-in theme presets.

> Note: This project must not copy any existing app’s UI, assets, copy, or branding. RepLedger is an original product in the strength-tracking category.

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
- Exercise library (seeded) + search/filter
- Exercise detail: About / History / Records / Charts (Charts partly gated)

### Rest timer
- Auto-start after set completion (configurable)
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
- macOS via **Mac Catalyst** (preferred)

---

## Setup

1. Open the Xcode project.
2. Select a target: iOS Simulator / iPad Simulator / “My Mac (Mac Catalyst)”.
3. Build & run.

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

> If the app includes a “mock purchases” dev toggle, you can use that too—StoreKit config is still the most realistic.

---

## Themes

RepLedger ships with 3 theme presets (selectable in Settings):
- **Obsidian** — premium dark, subtle gradients
- **Studio** — clean editorial light theme
- **Forge** — bold athletic contrast

All screens should use reusable components so theme switching is genuine (token-based).

---

## Architecture (high level)

- SwiftUI + MVVM
- SwiftData persistence (offline-first)
- Services:
  - `MetricsService` (volume, e1RM, PR detection)
  - `PurchaseManager` (StoreKit 2)
  - `EntitlementsService` (isPro / isCoach gating)
  - `SyncEngine` protocol (LocalOnly v1, Remote stub for v1.5)

Suggested folder structure:
- `App/`
- `Models/`
- `Services/`
- `UIComponents/`
- `Features/`
- `Utilities/`

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
