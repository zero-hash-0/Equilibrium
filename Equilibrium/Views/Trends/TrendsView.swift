import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \CheckIn.date, order: .forward) private var checkIns: [CheckIn]
    @State private var vm = TrendsViewModel()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    header
                    rangePicker
                    if vm.stressSeries(from: checkIns).isEmpty {
                        EmptyStateView(
                            icon: "chart.xyaxis.line",
                            title: "No Data Yet",
                            message: "Complete check-ins to see your wellness trends here."
                        )
                        .padding(.top, 60)
                    } else {
                        stressChart
                        wellnessChart
                        urgeChart
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

    private func chartCard<C: View>(title: String, icon: String, accent: Color, @ViewBuilder chart: () -> C) -> some View {
        TitledCard(title: title, icon: icon, accent: accent) { chart() }
    }
}
