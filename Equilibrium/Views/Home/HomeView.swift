import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Int
    @Query private var profiles: [UserProfile]
    @Query(sort: \CheckIn.createdAt, order: .reverse) private var checkIns: [CheckIn]
    @State private var vm = HomeViewModel()
    @State private var showCheckIn = false
    @State private var showAlreadyCheckedIn = false
    @State private var existingCheckIn: CheckIn? = nil

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    headerSection
                    wellnessCard
                    checkInCard
                    if let insight = vm.latestInsight(from: checkIns) {
                        insightCard(insight)
                    }
                    trendButton
                }
                .padding(.horizontal, Theme.lg)
                .padding(.top, Theme.md)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCheckIn) {
            CheckInFlowView()
        }
        .alert("Already Checked In", isPresented: $showAlreadyCheckedIn) {
            if existingCheckIn?.insight != nil {
                Button("View Coach") {
                    showCheckIn = true
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've already completed today's check-in.")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text("Hello, \(profile?.name ?? "there") 👋")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.accentMint.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.accentMint)
            }
        }
        .padding(.top, Theme.md)
    }

    private var wellnessCard: some View {
        TitledCard(title: "Financial Wellness Score", icon: "heart.fill") {
            let score = vm.wellnessScore(from: checkIns)
            HStack(spacing: Theme.lg) {
                WellnessRing(score: score ?? 50, dimmed: score == nil)
                VStack(alignment: .leading, spacing: 6) {
                    if let score {
                        Text(WellnessScore.label(for: score))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(WellnessScore.explanation(for: score))
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("No data yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Complete your first check-in to see your score.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
        }
    }

    private var checkInCard: some View {
        let today = vm.todayCheckIn(from: checkIns)
        return TitledCard(title: "Today's Check-In", icon: "calendar.badge.checkmark",
            accessory: {
                statusBadge(done: today != nil)
            }) {
            PrimaryButton(title: today == nil ? "Start Check-In" : "View Today's Check-In") {
                let todayCI = vm.todayCheckIn(from: checkIns)
                if todayCI != nil {
                    existingCheckIn = todayCI
                    showAlreadyCheckedIn = true
                } else {
                    showCheckIn = true
                }
            }
        }
    }

    private func statusBadge(done: Bool) -> some View {
        Text(done ? "Done" : "Not done")
            .font(.caption).fontWeight(.semibold)
            .foregroundStyle(done ? .black : Theme.textSecondary)
            .padding(.horizontal, Theme.xs).padding(.vertical, 4)
            .background(done ? Theme.accentMint : Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    private func insightCard(_ insight: AIInsight) -> some View {
        TitledCard(title: "Latest AI Insight", icon: "sparkles") {
            Text(insight.insightText)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(3)
        }
    }

    private var trendButton: some View {
        HStack(spacing: Theme.sm) {
            SecondaryButton(title: "View Trends", icon: "chart.line.uptrend.xyaxis") {
                selectedTab = 1
            }
            SecondaryButton(title: "Settings", icon: "gearshape.fill") {
                selectedTab = 2
            }
        }
    }
}

// MARK: - Wellness Ring
private struct WellnessRing: View {
    let score: Int
    var dimmed: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.accentMint.opacity(0.15), lineWidth: 10)
            Circle()
                .trim(from: 0, to: dimmed ? 0 : CGFloat(score) / 100)
                .stroke(
                    Theme.accentGradient,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8), value: score)
            VStack(spacing: 1) {
                Text(dimmed ? "—" : "\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(dimmed ? Theme.textSecondary : Theme.accentMint)
                if !dimmed {
                    Text("/ 100").font(.caption2).foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(width: 100, height: 100)
    }
}
