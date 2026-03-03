import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \CheckIn.date, order: .forward) private var checkIns: [CheckIn]
    @State private var vm = TrendsViewModel()

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
                        rangePicker
                        if checkIns.isEmpty {
                            emptyState
                        } else {
                            stressChart
                            wellnessChart
                            urgeChart
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trends")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Your financial wellness over time")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $vm.selectedRange) {
            ForEach(TrendRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .tint(Color.eqMint)
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.eqMint.opacity(0.5))
                Text("No data yet")
                    .font(.headline).foregroundStyle(.white)
                Text("Complete your first check-in to see trends.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private var stressChart: some View {
        trendCard(title: "Stress Level", icon: "waveform.path.ecg", accent: .orange) {
            let points = vm.stressTrend(from: checkIns)
            Chart(points) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Stress", point.value)
                )
                .foregroundStyle(Color.orange.gradient)
                .interpolationMethod(.catmullRom)
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Stress", point.value)
                )
                .foregroundStyle(Color.orange.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 1...10)
            .frame(height: 140)
        }
    }

    private var wellnessChart: some View {
        trendCard(title: "Wellness Score", icon: "heart.fill", accent: Color.eqMint) {
            let points = vm.wellnessTrend(from: checkIns)
            Chart(points) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.value)
                )
                .foregroundStyle(Color.eqMint.gradient)
                .interpolationMethod(.catmullRom)
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.value)
                )
                .foregroundStyle(Color.eqMint.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .frame(height: 140)
        }
    }

    private var urgeChart: some View {
        trendCard(title: "Spending Urge Intensity", icon: "cart.badge.questionmark", accent: .cyan) {
            let points = vm.urgeFrequency(from: checkIns)
            Chart(points) { point in
                BarMark(
                    x: .value("Date", point.date),
                    y: .value("Urge", point.value)
                )
                .foregroundStyle(Color.cyan.opacity(0.8).gradient)
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2]) { val in
                    AxisGridLine()
                    AxisValueLabel {
                        switch val.index {
                        case 0: Text("None")
                        case 1: Text("Mild")
                        default: Text("Strong")
                        }
                    }
                }
            }
            .frame(height: 140)
        }
    }

    private func trendCard<C: View>(title: String, icon: String, accent: Color, @ViewBuilder chart: () -> C) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label(title, systemImage: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                chart()
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .foregroundStyle(Color.secondary)
                        }
                    }
            }
        }
    }
}
