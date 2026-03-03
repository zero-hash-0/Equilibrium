import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \CheckIn.createdAt, order: .reverse) private var checkIns: [CheckIn]
    @Query private var profiles: [UserProfile]
    @State private var vm = HomeViewModel()
    @State private var showCheckIn = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.eqGraphite, Color.eqSlate],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        wellnessScoreCard
                        checkInStatusCard
                        if let insight = vm.latestInsight {
                            latestInsightCard(insight: insight)
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear { vm.refresh(checkIns: checkIns) }
            .onChange(of: checkIns.count) { _, _ in vm.refresh(checkIns: checkIns) }
            .fullScreenCover(isPresented: $showCheckIn) {
                CheckInFlowView()
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Hello, \(profile?.name ?? "there") 👋")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.eqMint)
        }
        .padding(.top, 16)
    }

    private var wellnessScoreCard: some View {
        GlassCard {
            HStack(spacing: 20) {
                WellnessRing(score: vm.wellnessScore)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Wellness Score")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(scoreDescription(vm.wellnessScore))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    private var checkInStatusCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Label("Today's Check-In", systemImage: "calendar.badge.checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    checkInBadge
                }
                PrimaryButton(title: vm.todayCheckIn == nil ? "Start Check-In" : "View Check-In") {
                    showCheckIn = true
                }
            }
        }
    }

    private var checkInBadge: some View {
        Group {
            if vm.todayCheckIn != nil {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color.eqMint)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.eqMint.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Text("Not done")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }

    private func latestInsightCard(insight: AIInsight) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Latest AI Insight", systemImage: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.eqMint)
                Text(insight.insightText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }

    private func scoreDescription(_ score: Int) -> String {
        switch score {
        case 75...: return "You're in great financial balance today."
        case 50..<75: return "Moderate wellness — a few small wins help."
        case 25..<50: return "Stress is elevated. One small step matters."
        default:    return "High stress detected. Be gentle with yourself."
        }
    }
}
