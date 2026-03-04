import SwiftUI

struct Step4GoalView: View {
    @Bindable var vm: CheckInViewModel
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.xl) {
                    stepHeader(icon: "flag.fill", title: "Today's Goal",
                               subtitle: "What's your top financial focus today?")
                    VStack(spacing: Theme.xs) {
                        ForEach(GoalToday.allCases, id: \.self) { goal in
                            selectionRow(label: goal.rawValue, selected: vm.goalToday == goal) {
                                vm.goalToday = goal
                            }
                        }
                    }
                    .padding(.horizontal, Theme.lg)
                }
                .padding(.top, Theme.sm)
            }
            PrimaryButton(title: "Next — Money Triggers →", action: onSubmit)
                .padding(.horizontal, Theme.lg)
                .padding(.bottom, Theme.xxl)
        }
    }
}
