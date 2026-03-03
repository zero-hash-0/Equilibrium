import SwiftUI
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    var showDeleteConfirmation = false
    var showShareSheet = false
    var exportURL: URL? = nil
    var exportError: String? = nil

    func exportData(profile: UserProfile, checkIns: [CheckIn]) {
        do {
            exportURL = try ExportService.buildExportURL(profile: profile, checkIns: checkIns)
            showShareSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    func deleteAll(modelContext: ModelContext) {
        try? modelContext.delete(model: AIInsight.self)
        try? modelContext.delete(model: CheckIn.self)
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.save()
    }
}
