# Equilibrium — AI Financial Wellness Coach

Premium SwiftUI iOS app combining daily financial check-ins with AI-powered coaching.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM + Swift Concurrency |
| Persistence | SwiftData |
| Networking | URLSession |
| Charts | Swift Charts |
| AI | OpenAI Chat Completions (configurable) |

---

## Setup

### 1. Add your API key

Open `Config/Debug.xcconfig` and replace `your_key_here`:

```
OPENAI_API_KEY = sk-proj-...yourkey...
OPENAI_MODEL   = gpt-4.1-mini
OPENAI_BASE_URL = https://api.openai.com/v1
```

> **Never commit your real key.** The `.gitignore` excludes `*.local.xcconfig`. Make a private copy:
> ```bash
> cp Config/Debug.xcconfig Config/Debug.local.xcconfig
> # Edit .local copy — never committed
> ```

### 2. Set Base Configuration in Xcode

1. Open `Equilibrium.xcodeproj`
2. Click the project → select target → **Build Settings**
3. Under **Configuration** → **Debug** → set Base Configuration to `Debug.xcconfig`
4. **Release** → set to `Release.xcconfig`

### 3. Run

Select an iPhone 15+ simulator → **⌘R**

The app compiles and runs with no API key (AI features show a friendly error; all other screens work fully).

### 4. Test the AI call

1. Complete onboarding (name, goal, baseline stress)
2. **Start Check-In** on Home
3. Fill all 4 steps → **Submit & Get Insights**
4. AI Coach screen calls the API and displays Insight / Action / If-Then

---

## File Structure

```
Equilibrium/
├── App/
│   ├── EquilibriumApp.swift       # @main, ModelContainer
│   ├── OnboardingGateView.swift   # Routes: onboarding or tabs
│   ├── MainTabView.swift          # Home | Trends | Settings tabs
│   └── Theme.swift                # Colors, spacing, corner radius
├── Models/
│   ├── Enums.swift                # PrimaryGoal, SpendingUrge, GoalToday
│   ├── UserProfile.swift          # @Model — name, goal, baseline stress
│   ├── CheckIn.swift              # @Model — daily check-in + wellness score
│   └── AIInsight.swift            # @Model — AI response + DTO
├── Services/
│   ├── AIService.swift            # Actor — URLSession OpenAI call
│   ├── Secrets.swift              # Bundle key reader (xcconfig → Info.plist)
│   └── ExportService.swift        # JSON export builder
├── Utils/
│   ├── DateHelpers.swift          # dayKey formatter, startOfDay
│   ├── WellnessScore.swift        # Score algorithm + explanation
│   ├── RateLimiter.swift          # UserDefaults-based daily rate limiter
│   └── ShareSheet.swift           # UIActivityViewController wrapper
├── ViewModels/                    # @MainActor @Observable classes
│   ├── OnboardingViewModel.swift
│   ├── HomeViewModel.swift
│   ├── CheckInViewModel.swift
│   ├── AICoachViewModel.swift     # Manages AI fetch + 3/day regen limit
│   ├── TrendsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Components/                # LiquidGlassCard, PrimaryButton, SecondaryButton,
│   │                              #   EmptyStateView, SegmentedToggle
│   ├── Onboarding/                # Welcome → Permissions → CreateProfile
│   ├── Home/HomeView.swift        # Dashboard: score, status, latest insight
│   ├── CheckIn/                   # 4-step flow (Step1–4 as separate files)
│   ├── Coach/AICoachView.swift    # Insight / Action / If-Then + regenerate
│   ├── Trends/TrendsView.swift    # 7/30-day Swift Charts
│   └── Settings/                  # SettingsView + EditProfileView
└── Resources/
    ├── Assets.xcassets
    └── Info.plist                  # Reads OPENAI_* from xcconfig

Config/
├── Debug.xcconfig                  # API key + model (set Base Configuration here)
└── Release.xcconfig
```

---

## Wellness Score Formula

```
score = 50
score += (6 - stressLevel) × 4      // stress 1→+20, stress 10→-16
score += urge: None=+12, Mild=+4, Strong=-10
score += (sleepQuality - 3) × 5     // optional; sleep 5→+10, sleep 1→-10
score = clamp(0, 100)
```

---

## MVP Checklist ✅

- [x] Onboarding — Welcome, Notifications, Create Profile
- [x] Home Dashboard — Wellness score ring, check-in status, latest insight card
- [x] Daily Check-In — 4-step animated flow, one per day enforcement
- [x] AI Coach — OpenAI call, Insight / Action / If-Then, retry on error
- [x] Regenerate — max 3/day rate limit via RateLimiter (UserDefaults)
- [x] Trends — 7/30-day toggle, 3 Swift Charts (stress, wellness, urge)
- [x] Settings — Edit profile, export JSON (share sheet), delete all data
- [x] SwiftData persistence — UserProfile, CheckIn, AIInsight with relationships
- [x] Secrets via xcconfig — never hardcoded
- [x] Runs with no API key — graceful error, all non-AI screens functional
- [x] Premium UI — frosted glass cards, mint/graphite palette, safe area aware

## Roadmap 🔜

- [ ] Plaid integration — pull real transaction data into check-ins
- [ ] Local notifications — daily check-in reminders
- [ ] Home Screen widget — today's wellness score
- [ ] iCloud sync — SwiftData + CloudKit
- [ ] Streak tracking — consecutive check-in days badge
- [ ] Advanced AI context — include recent spending patterns in prompt
