import SwiftUI

struct Step3SleepView: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.xl) {
                    stepHeader(icon: "moon.stars.fill", title: "Sleep Quality",
                               subtitle: "How well did you sleep last night?")
                    LiquidGlassCard {
                        VStack(spacing: Theme.md) {
                            Toggle("Track sleep quality", isOn: $vm.sleepEnabled)
                                .tint(Theme.accentMint)
                                .foregroundStyle(Theme.textPrimary)
                            if vm.sleepEnabled {
                                Divider().background(Theme.strokeOverlay)
                                HStack {
                                    Text("Quality")
                                        .font(.subheadline).foregroundStyle(Theme.textSecondary)
                                    Spacer()
                                    Text("\(Int(vm.sleepQuality)) / 5")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.accentMint)
                                }
                                Slider(value: $vm.sleepQuality, in: 1...5, step: 1).tint(Theme.accentMint)
                                HStack {
                                    Text("😴 Poor").font(.caption2).foregroundStyle(Theme.textSecondary)
                                    Spacer()
                                    Text("😊 Great").font(.caption2).foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: vm.sleepEnabled)
                    .padding(.horizontal, Theme.lg)
                }
                .padding(.top, Theme.sm)
            }
            VStack(spacing: Theme.sm) {
                PrimaryButton(title: "Next", action: vm.nextStep)
                if !vm.sleepEnabled {
                    SecondaryButton(title: "Skip", action: vm.nextStep)
                }
            }
            .padding(.horizontal, Theme.lg)
            .padding(.bottom, Theme.xxl)
        }
    }
}
