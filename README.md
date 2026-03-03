# Equilibrium — AI Financial Wellness Coach

A premium SwiftUI iOS app that combines daily financial check-ins with AI-powered coaching insights.

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

### 1. Add your API key via `.xcconfig`

The project reads AI credentials from `Info.plist`, which pulls them from the active `.xcconfig`.

**Steps:**
1. Open `Config/Development.xcconfig`
2. Replace `sk-YOUR_KEY_HERE` with your actual OpenAI API key
3. Optionally change `AI_MODEL` (default: `gpt-4o-mini`) or `AI_BASE_URL`

> **Never commit your real key.** The `.gitignore` already excludes `*.xcconfig.local`. You can make a private copy:
> ```bash
> cp Config/Development.xcconfig Config/Development.local.xcconfig
> # Edit the .local copy — it will never be committed
> ```

### 2. Open in Xcode

```bash
open Equilibrium.xcodeproj
```

Select an iPhone 15 simulator, then **Run (⌘R)**.

### 3. Test the AI call

1. Complete onboarding (name, goal, baseline stress)
2. Tap **Start Check-In** on the home screen
3. Fill in all 4 steps and tap **Submit & Get Insights**
4. The AI Coach screen will call the API and display your personalized insight

---

## Project Structure

```
Equilibrium/
├── App/
│   ├── EquilibriumApp.swift       # @main, ModelContainer setup
│   └── RootView.swift             # Onboarding vs. MainTabView router
├── Models/
│   ├── UserProfile.swift          # @Model — name, goal, baseline stress
│   ├── CheckIn.swift              # @Model — daily check-in data
│   └── AIInsight.swift            # @Model — AI response + DTO
├── Services/
│   └── AIService.swift            # URLSession AI call, rate limiting
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── HomeViewModel.swift
│   ├── CheckInViewModel.swift
│   ├── CoachViewModel.swift       # Manages AI fetch + regenerate
│   ├── TrendsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── MainTabView.swift          # TabView: Home | Trends | Settings
│   ├── Onboarding/                # Welcome → Permissions → Create Profile
│   ├── Home/                      # Dashboard with score, CTA, latest insight
│   ├── CheckIn/                   # 4-step flow (stress, urge, sleep, goal)
│   ├── Coach/                     # AI insight display + regenerate
│   ├── Trends/                    # 7/30-day Swift Charts
│   ├── Settings/                  # Edit profile, export JSON, delete data
│   └── Components/                # GlassCard, WellnessRing, PrimaryButton
├── Utils/
│   ├── WellnessScoreCalculator.swift
│   └── Extensions.swift           # Color palette, Date helpers, ViewModifiers
└── Resources/
    ├── Assets.xcassets
    └── Info.plist                  # Reads AI_API_KEY etc. from xcconfig
Config/
└── Development.xcconfig           # API key, base URL, model name
```

---

## Wellness Score Formula

```
score = 50
score += lerp(stress, 1..10, +20..-20)   // lower stress = higher score
score += urge: None=+15, Mild=0, Strong=-15
score += lerp(sleep, 1..5, -10..+10)     // optional
score = clamp(0, 100)
```

---

## MVP Implemented ✅

- [x] Onboarding (Welcome → Notifications → Create Profile)
- [x] Home Dashboard (Wellness Score ring, check-in status, latest insight)
- [x] Daily Check-In 4-step flow
- [x] AI Coach screen (fetch, display, regenerate with 3/day rate limit)
- [x] Trends (7/30-day toggle, Stress / Wellness / Urge charts)
- [x] Settings (edit profile, export JSON, delete all data)
- [x] SwiftData persistence (UserProfile, CheckIn, AIInsight)
- [x] API key via `.xcconfig` (never hardcoded)
- [x] Premium Apple-tier UI (frosted glass, mint/slate palette, SF Symbols)

## Coming Next 🔜

- [ ] Plaid integration — auto-pull real spending data
- [ ] Notification scheduling — daily check-in reminders
- [ ] Widget — Today's wellness score on Home Screen
- [ ] iCloud sync — SwiftData CloudKit backend
- [ ] Advanced AI prompt — include spending history context
- [ ] Streak tracking — consecutive check-in days
