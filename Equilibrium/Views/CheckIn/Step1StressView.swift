import SwiftUI

struct Step1StressView: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.xl) {
                    stepHeader(icon: "waveform.path.ecg", title: "Stress Level",
                               subtitle: "How stressed are you feeling right now?")
                    LiquidGlassCard {
                        VStack(spacing: Theme.md) {
                            Text("\(Int(vm.stressLevel))")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(stressColor)
                                .animation(.easeInOut, value: vm.stressLevel)
                            Slider(value: $vm.stressLevel, in: 1...10, step: 1)
                                .tint(stressColor)
                            HStack {
                                Text("😌 Calm").font(.caption2).foregroundStyle(Theme.textSecondary)
                                Spacer()
                                Text("😰 Very Stressed").font(.caption2).foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.lg)
                }
                .padding(.top, Theme.sm)
            }
            PrimaryButton(title: "Next", action: vm.nextStep)
                .padding(.horizontal, Theme.lg)
                .padding(.bottom, Theme.xxl)
        }
    }

    private var stressColor: Color {
        switch Int(vm.stressLevel) {
        case 1...3: return Theme.accentMint
        case 4...6: return .yellow
        default:    return .orange
        }
    }
}

func stepHeader(icon: String, title: String, subtitle: String) -> some View {
    VStack(spacing: Theme.sm) {
        Image(systemName: icon)
            .font(.system(size: 44))
            .foregroundStyle(Theme.accentMint)
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.textPrimary)
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(Theme.textSecondary)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, Theme.xl)
}
