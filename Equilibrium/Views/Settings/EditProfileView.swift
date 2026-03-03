import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let profile: UserProfile

    @State private var name: String = ""
    @State private var goal: PrimaryGoal = .buildSavings
    @State private var stress: Double = 5
    @State private var nameError: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.xl) {
                        nameField
                        goalPicker
                        stressSlider
                    }
                    .padding(.horizontal, Theme.xl)
                    .padding(.top, Theme.xl)
                    .padding(.bottom, Theme.xxl)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.accentMint)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.accentMint)
                }
            }
            .onAppear {
                name   = profile.name
                goal   = profile.primaryGoal
                stress = Double(profile.baselineStress)
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            Label("Name", systemImage: "person.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.accentMint)
            TextField("Your name", text: $name)
                .padding(Theme.md)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(Theme.textPrimary)
            if let err = nameError {
                Text(err).font(.caption).foregroundStyle(Theme.destructive)
            }
        }
    }

    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            Label("Primary Goal", systemImage: "flag.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.accentMint)
            VStack(spacing: Theme.xs) {
                ForEach(PrimaryGoal.allCases, id: \.self) { g in
                    let selected = goal == g
                    Button { goal = g } label: {
                        HStack {
                            Text(g.rawValue).font(.system(size: 15, weight: .medium))
                                .foregroundStyle(selected ? .black : Theme.textPrimary)
                            Spacer()
                            if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(.black) }
                        }
                        .padding(.horizontal, Theme.md).padding(.vertical, 14)
                        .background(selected ? Theme.accentMint : Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .animation(.easeInOut(duration: 0.18), value: selected)
                }
            }
        }
    }

    private var stressSlider: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            Label("Baseline Stress: \(Int(stress))", systemImage: "waveform.path.ecg")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.accentMint)
            LiquidGlassCard {
                VStack(spacing: Theme.sm) {
                    Slider(value: $stress, in: 1...10, step: 1).tint(Theme.accentMint)
                    HStack {
                        Text("Calm").font(.caption2).foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text("Very Stressed").font(.caption2).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { nameError = "Name is required."; return }
        profile.name = trimmed
        profile.primaryGoal = goal
        profile.baselineStress = Int(stress)
        profile.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
}
