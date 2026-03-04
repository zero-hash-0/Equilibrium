# Equilibrium — AI Financial Wellness Coach

> A premium iOS app that helps you build better financial habits through daily check-ins, AI-powered insights, and impulse spending intervention.

## Tech Stack

- **Language**: Swift 6
- **Framework**: SwiftUI (iOS 17+)
- **Architecture**: MVVM + `@Observable`
- **Persistence**: SwiftData
- **Networking**: URLSession (no third-party dependencies)
- **Charts**: Swift Charts
- **AI**: OpenAI Chat Completions API

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/zero-hash-0/Equilibrium.git
cd Equilibrium
```

### 2. Configure your API key

Open `Config/Debug.xcconfig` and replace the placeholder:

```
OPENAI_API_KEY = your_actual_openai_key_here
OPENAI_MODEL = gpt-4.1-mini
OPENAI_BASE_URL = https://api.openai.com/v1
```

> **Important:** `Debug.xcconfig` is git-ignored. Never commit your API key.

### 3. Open in Xcode

```bash
open Equilibrium.xcodeproj
```

Select your target device or simulator (iOS 17+) and press **⌘R** to build and run.

---

## How to Run

1. Open `Equilibrium.xcodeproj` in Xcode 15+
2. Set your development team in **Signing & Capabilities**
3. Select an iOS 17+ simulator or device
4. Build & Run (`⌘R`)

On first launch the app shows onboarding (name, goal, baseline stress).  
After completing onboarding you land on the Home screen.

---

## How to Test the AI Coach

1. Complete a daily check-in (tap **Start Check-In** on Home)
2. Fill in Stress Level, Spending Urge, Sleep Quality, Goal, and Money Triggers
3. After submission you're taken to the **AI Coach** screen
4. The coach calls the OpenAI API and returns:
   - 💡 **Insight** — a short punchy observation
   - ⚡ **One Small Action** — something to do right now
   - 🧠 **If-Then Plan** — a concrete coping strategy
5. Tap **Regenerate** to get a new coaching response (max 3/day)

### Testing without an API key

The app **fully works without an API key**. It falls back to curated static coaching responses. This makes it safe to demo and test on TestFlight without exposing credentials.

---

## Key Features

| Feature | Description |
|---|---|
| Daily Check-In | 5-step flow: Stress → Urge → Sleep → Goal → Money Triggers |
| AI Coach | GPT-powered insights, actions, and if-then plans |
| Impulse Mode | Real-time 3-step intervention when feeling an urge to spend |
| Impulse Wins | Track every purchase you paused — shows weekly count + estimated savings |
| Financial Wellness Score | Computed score (0–100) based on stress, urge, and sleep |
| Trends | Swift Charts showing stress, wellness, urge intensity, impulse wins, urge frequency |
| Data Export | Export all data as JSON via share sheet |
| Secure Secrets | API key read from xcconfig → Info.plist, never hardcoded |

---

## Wellness Score Formula

```
score = 50
score += (6 - stressLevel) * 4          // stress adjustment
score += urge == .none  ? +12 : 0        // urge bonus
score += urge == .mild  ? +4  : 0
score += urge == .strong ? -10 : 0
score += (sleepQuality - 3) * 5         // sleep adjustment (optional)
score = clamp(score, 0, 100)
```

---

## Project Structure

```
Equilibrium/
├── App/
│   ├── EquilibriumApp.swift       # Entry point, SwiftData container
│   ├── MainTabView.swift          # Tab bar (Home / Trends / Settings)
│   ├── OnboardingGateView.swift   # Profile gate
│   └── Theme.swift                # Design tokens
├── Models/
│   ├── UserProfile.swift
│   ├── CheckIn.swift              # Includes Money Trigger fields
│   ├── AIInsight.swift
│   ├── ImpulseWin.swift           # Win tracking model
│   └── Enums.swift                # All app enums
├── Services/
│   ├── AIService.swift            # OpenAI actor
│   ├── Secrets.swift              # xcconfig reader
│   └── ExportService.swift        # JSON export
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── CheckInViewModel.swift     # 5-step state machine
│   ├── AICoachViewModel.swift     # Rate-limited AI calls
│   ├── TrendsViewModel.swift      # Chart data series
│   ├── OnboardingViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Components/                # LiquidGlassCard, TitledCard, Buttons, etc.
│   ├── Home/                      # HomeView + ImpulseModeView
│   ├── CheckIn/                   # 5-step check-in flow
│   ├── Coach/                     # AICoachView
│   ├── Trends/                    # TrendsView with Swift Charts
│   ├── Settings/                  # SettingsView + EditProfileView
│   └── Onboarding/               # Welcome → Permissions → CreateProfile
└── Utils/
    ├── WellnessScore.swift
    ├── DateHelpers.swift
    ├── RateLimiter.swift          # Max 3 AI regenerations/day
    └── ShareSheet.swift
```

---

## TestFlight Beta Notes

- The app requires iOS 17.0+
- No external accounts required — all data is local (SwiftData)
- AI features require an OpenAI API key configured in xcconfig
- The app works fully without a key (static fallback responses)
- Bundle ID: `com.equilibrium.app`

---

## Roadmap

- [ ] Apple Watch companion (urge notification + quick pause)
- [ ] Lock Screen widget (Wellness Score + Quick Check-In)
- [ ] Spending Triggers Heatmap (day × time heat map)
- [ ] Premium tier ($8–12/mo): Unlimited AI, Impulse Mode history, behavior programs

---

## License

Private — All rights reserved.
