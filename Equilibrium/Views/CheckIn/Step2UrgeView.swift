import SwiftUI

struct Step2UrgeView: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.xl) {
                    stepHeader(icon: "cart.badge.questionmark", title: "Spending Urges",
                               subtitle: "Any urge to spend impulsively today?")
                    VStack(spacing: Theme.xs) {
                        ForEach(SpendingUrge.allCases, id: \.self) { urge in
                            selectionRow(label: urge.rawValue, selected: vm.spendingUrge == urge) {
                                vm.spendingUrge = urge
                            }
                        }
                    }
                    .padding(.horizontal, Theme.lg)

                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: Theme.xs) {
                            Text("Optional note")
                                .font(.caption).fontWeight(.semibold).foregroundStyle(Theme.accentMint)
                            TextField("What triggered it? (optional)", text: $vm.note, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                                .foregroundStyle(Theme.textPrimary)
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
}

func selectionRow(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(selected ? .black : Theme.textPrimary)
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.black)
            }
        }
        .padding(.horizontal, Theme.md)
        .padding(.vertical, 15)
        .background(selected ? Theme.accentMint : Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .animation(.easeInOut(duration: 0.18), value: selected)
}
