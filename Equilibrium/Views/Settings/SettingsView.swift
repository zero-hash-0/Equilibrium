import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @Query private var checkIns: [CheckIn]
    @State private var vm = SettingsViewModel()
    @State private var editName = ""
    @State private var editGoal: PrimaryGoal = .buildSavings
    @State private var editStress: Double = 5
    @State private var isEditing = false

    private var profile: UserProfile? { profiles.first }

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
                        profileCard
                        dataSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
            .confirmationDialog(
                "Delete All Data",
                isPresented: $vm.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    vm.deleteAll(context: context)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove your profile, check-ins, and AI insights.")
            }
            .sheet(isPresented: $vm.showShareSheet) {
                if let url = vm.exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var profileCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Profile", systemImage: "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.eqMint)
                    Spacer()
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing { saveProfile() }
                        else { beginEdit() }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.eqMint)
                }

                Divider().background(.secondary.opacity(0.3))

                if isEditing {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Name", text: $editName)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .foregroundStyle(.white)

                        Picker("Primary Goal", selection: $editGoal) {
                            ForEach(PrimaryGoal.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.eqMint)

                        HStack {
                            Text("Baseline Stress: \(Int(editStress))")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Spacer()
                        }
                        Slider(value: $editStress, in: 1...10, step: 1).tint(Color.eqMint)
                    }
                } else if let p = profile {
                    settingsRow(label: "Name", value: p.name)
                    settingsRow(label: "Primary goal", value: p.primaryGoal)
                    settingsRow(label: "Baseline stress", value: "\(p.baselineStress) / 10")
                    settingsRow(label: "Member since", value: p.createdAt.shortFormatted)
                }
            }
        }
    }

    private var dataSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Data", systemImage: "externaldrive.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.eqMint)
                Divider().background(.secondary.opacity(0.3))

                Button {
                    if let p = profile {
                        vm.exportData(checkIns: checkIns, profile: p)
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Data as JSON")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                }

                Divider().background(.secondary.opacity(0.2))

                Button {
                    vm.showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete All Data")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.red)
                }
            }
        }
    }

    private var aboutSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("About", systemImage: "info.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.eqMint)
                Divider().background(.secondary.opacity(0.3))
                settingsRow(label: "Version", value: appVersion)
                settingsRow(label: "Build", value: buildNumber)
            }
        }
    }

    private func settingsRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium).foregroundStyle(.white)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private func beginEdit() {
        guard let p = profile else { return }
        editName   = p.name
        editGoal   = p.primaryGoalEnum
        editStress = Double(p.baselineStress)
        isEditing  = true
    }

    private func saveProfile() {
        guard let p = profile else { return }
        p.name          = editName.trimmingCharacters(in: .whitespaces)
        p.primaryGoal   = editGoal.rawValue
        p.baselineStress = Int(editStress)
        p.updatedAt     = Date()
        try? context.save()
        isEditing = false
    }
}

// MARK: - ShareSheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
