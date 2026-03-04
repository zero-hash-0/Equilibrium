import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \CheckIn.date, order: .forward) private var checkIns: [CheckIn]
    @Query(sort: \ImpulseWin.createdAt, order: .forward) private var impulseWins: [ImpulseWin]
    @State private var vm = TrendsViewModel()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    header
                    rangePicker
                    if vm.stressSeries(from: checkIns).isEmpty && vm.impulseWinSeries(from: impulseWins).isEmpty {
                        EmptyStateView(
                            icon: "chart.xyaxis.line",
                            title: "No Data Yet",
                            message: "Complete check-ins to see your wellness trends here."
                        )
                        .padding(.top, 60)
                    } else {
                        if !vm.stressSeries(from: checkIns).isEmpty {
                            stressChart
                            wellnessChart
                            urgeChart
                        }
                        impulseWinsChart
                        urgeFrequencyChart
                    }
                }
                .padding(.horizontal, Theme.lg)
                .padding(.top, Theme.md)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trends")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("Your wellness over time")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(.top, Theme.md)
    }

    private var rangePicker: some View {
        SegmentedToggle(
            selection: $vm.rangeDays,
            options: [("7 Days", 7), ("30 Days", 30)]
        )
    }

    private var stressChart: some View {
        chartCard(title: "Stress Level", icon: "waveform.path.ecg", accent: .orange) {
            Chart(vm.stressSeries(from: checkIns)) { pt in
                LineMark(x: .value("Date", pt.date), y: .value("Stress", pt.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.orange.gradient)
                AreaMark(x: .value("Date", pt.date), y: .value("Stress", pt.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.orange.opacity(0.08).gradient)
            }
            .chartYScale(domain: 1...10)
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.textSecondary)
            }}
            .frame(height: 140)
        }
    }

    private var wellnessChart: some View {
        chartCard(title: "Wellness Score", icon: "heart.fill", accent: Theme.accentMint) {
            Chart(vm.wellnessSeries(from: checkIns)) { pt in
                LineMark(x: .value("Date", pt.date), y: .value("Score", pt.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Theme.accentMint.gradient)
                AreaMark(x: .value("Date", pt.date), y: .value("Score", pt.value))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Theme.accentMint.opacity(0.08).gradient)
            }
            .chartYScale(domain: 0...100)
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.textSecondary)
            }}
            .frame(height: 140)
        }
    }

    private var urgeChart: some View {
        chartCard(title: "Spending Urge Intensity", icon: "cart.badge.questionmark", accent: Theme.accentCyan) {
            Chart(vm.urgeSeries(from: checkIns)) { pt in
                BarMark(x: .value("Date", pt.date), y: .value("Urge", pt.value))
                    .foregroundStyle(Theme.accentCyan.opacity(0.8).gradient)
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2]) { val in
                    AxisGridLine()
                    AxisValueLabel {
                        switch val.index {
                        case 0: Text("None").foregroundStyle(Theme.textSecondary)
                        case 1: Text("Mild").foregroundStyle(Theme.textSecondary)
                        default: Text("Strong").foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.textSecondary)
            }}
            .frame(height: 140)
        }
    }

    private var impulseWinsChart: some View {
        chartCard(title: "Impulse Wins", icon: "trophy.fill", accent: .orange) {
            let series = vm.impulseWinSeries(from: impulseWins)
            if series.isEmpty {
                Text("No impulse wins recorded yet.\nUse Impulse Mode to start tracking.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.lg)
            } else {
                Chart(series) { pt in
                    BarMark(x: .value("Date", pt.date), y: .value("Wins", pt.value))
                        .foregroundStyle(Color.orange.opacity(0.8).gradient)
                        .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { val in
                        AxisGridLine()
                        AxisValueLabel().foregroundStyle(Theme.textSecondary)
                    }
                }
                .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Theme.textSecondary)
                }}
                .frame(height: 140)
            }
        }
    }

    private var urgeFrequencyChart: some View {
        chartCard(title: "Urge Frequency", icon: "chart.bar.fill", accent: Theme.accentCyan) {
            let freq = vm.urgeFrequency(from: checkIns)
            if freq.allSatisfy({ $0.count == 0 }) {
                Text("No urge data yet.\nComplete check-ins to see frequency.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.lg)
            } else {
                Chart(freq) { pt in
                    BarMark(x: .value("Level", pt.label), y: .value("Count", pt.count))
                        .foregroundStyle(pt.color.gradient)
                        .cornerRadius(6)
                    RuleMark(y: .value("Count", pt.count))
                        .opacity(0)
                        .annotation(position: .top, alignment: .center) {
                            if pt.count > 0 {
                                Text("\(pt.count)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine()
                        AxisValueLabel().foregroundStyle(Theme.textSecondary)
                    }
                }
                .frame(height: 140)
            }
        }
    }

    private func chartCard(title: String, icon: String, accent: Color, @ViewBuilder chart: @escaping () -> some View) -> some View {
        TitledCard(title: title, icon: icon, accent: accent, content: chart)
    }
}
