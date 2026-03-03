import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var checkIns: [CheckIn]
    @State private var vm = SettingsViewModel()
    @State private var showEditProfile = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    header
                    if let p = profile { profileSection(p) }
                    dataSection
                    aboutSection
                }
                .padding(.horizontal, Theme.lg)
                .padding(.top, Theme.md)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfile) {
            if let p = profile { EditProfileView(profile: p) }
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportURL { ShareSheet(items: [url]) }
        }
        .confirmationDialog("Delete All Data", isPresented: $vm.showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) { vm.deleteAll(modelContext: modelContext) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove your profile, all check-ins, and AI insights.")
        }
        .alert("Export Error", isPresented: .constant(vm.exportError != nil)) {
            Button("OK") { vm.exportError = nil }
        } message: { Text(vm.exportError ?? "") }
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
        }
        .padding(.top, Theme.md)
    }

    private func profileSection(_ p: UserProfile) -> some View {
        TitledCard(title: "Profile", icon: "person.fill",
            accessory: {
                Button("Edit") { showEditProfile = true }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.accentMint)
            }) {
            VStack(spacing: Theme.xs) {
                settingsRow("Name", value: p.name)
                settingsRow("Goal", value: p.primaryGoalRaw)
                settingsRow("Baseline Stress", value: "\(p.baselineStress) / 10")
                settingsRow("Member Since", value: p.createdAt.formatted(date: .medium, time: .omitted))
            }
        }
    }

    private var dataSection: some View {
        TitledCard(title: "Data", icon: "externaldrive.fill") {
            VStack(spacing: Theme.sm) {
                SecondaryButton(title: "Export Data as JSON", icon: "square.and.arrow.up") {
                    if let p = profile { vm.exportData(profile: p, checkIns: checkIns) }
                }
                SecondaryButton(title: "Delete All Data", icon: "trash.fill", destructive: true) {
                    vm.showDeleteConfirmation = true
                }
            }
        }
    }

    private var aboutSection: some View {
        TitledCard(title: "About", icon: "info.circle.fill") {
            VStack(spacing: Theme.xs) {
                settingsRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                settingsRow("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                settingsRow("AI Model", value: Secrets.openAIModel)
            }
        }
    }

    private func settingsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium).foregroundStyle(Theme.textPrimary)
        }
    }
}
