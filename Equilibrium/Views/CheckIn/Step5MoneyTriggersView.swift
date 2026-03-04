import SwiftUI

struct Step5MoneyTriggersView: View {
    @Bindable var vm: CheckInViewModel
    let onSubmit: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Theme.lg) {
                // Header
                VStack(spacing: Theme.xs) {
                    Text("💸")
                        .font(.system(size: 44))
                    Text("Money Triggers")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Optional — helps us find your patterns")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.md)
                .padding(.horizontal, Theme.xl)

                // Trigger
                sectionCard(title: "Trigger", icon: "bolt.fill", accent: .orange) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.xs) {
                        ForEach(ImpulseTrigger.allCases) { trigger in
                            triggerChip(
                                label: trigger.rawValue,
                                icon: trigger.icon,
                                color: trigger.color,
                                isSelected: vm.selectedMoneyTrigger == trigger
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    vm.selectedMoneyTrigger = vm.selectedMoneyTrigger == trigger ? nil : trigger
                                }
                            }
                        }
                    }
                }

                // Time
                sectionCard(title: "Time of Day", icon: "clock.fill", accent: Theme.accentCyan) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.xs) {
                        ForEach(TriggerTime.allCases, id: \.rawValue) { time in
                            triggerChip(
                                label: "\(time.icon) \(time.rawValue)",
                                icon: nil,
                                color: Theme.accentCyan,
                                isSelected: vm.selectedTriggerTime == time
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    vm.selectedTriggerTime = vm.selectedTriggerTime == time ? nil : time
                                }
                            }
                        }
                    }
                }

                // Emotion
                sectionCard(title: "Emotion", icon: "heart.fill", accent: Theme.accentMint) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.xs) {
                        ForEach(MoneyEmotion.allCases, id: \.rawValue) { emotion in
                            triggerChip(
                                label: "\(emotion.icon) \(emotion.rawValue)",
                                icon: nil,
                                color: Theme.accentMint,
                                isSelected: vm.selectedEmotion == emotion
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    vm.selectedEmotion = vm.selectedEmotion == emotion ? nil : emotion
                                }
                            }
                        }
                    }
                }

                // Spending Category
                sectionCard(title: "Category", icon: "cart.fill", accent: .purple.opacity(0.85)) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.xs) {
                        ForEach(SpendingCategory.allCases, id: \.rawValue) { cat in
                            triggerChip(
                                label: "\(cat.icon) \(cat.rawValue)",
                                icon: nil,
                                color: .purple.opacity(0.85),
                                isSelected: vm.selectedCategory == cat
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    vm.selectedCategory = vm.selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                    }
                }

                // Submit
                VStack(spacing: Theme.sm) {
                    PrimaryButton(title: "Finish & Get Coaching →", action: onSubmit)
                    Button("Skip for now") { onSubmit() }
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, Theme.lg)
        }
    }

    private func sectionCard<C: View>(title: String, icon: String, accent: Color, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: Theme.sm) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accent)
            content()
        }
        .padding(Theme.md)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Theme.strokeOverlay, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func triggerChip(label: String, icon: String?, color: Color, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                        .foregroundStyle(isSelected ? color : Theme.textSecondary)
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(isSelected ? color.opacity(0.15) : Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? color.opacity(0.4) : Color.white.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
