import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var showDeleteConfirmation = false
    var exportURL: URL? = nil
    var showShareSheet = false

    func exportData(checkIns: [CheckIn], profile: UserProfile) {
        struct ExportCheckIn: Codable {
            let date: String
            let stressLevel: Int
            let spendingUrge: String
            let sleepQuality: Int?
            let goalToday: String
            let note: String?
            let wellnessScore: Int
        }
        struct Export: Codable {
            let profile: ExportProfile
            let checkIns: [ExportCheckIn]
        }
        struct ExportProfile: Codable {
            let name: String
            let primaryGoal: String
            let baselineStress: Int
        }

        let data = Export(
            profile: .init(name: profile.name, primaryGoal: profile.primaryGoal, baselineStress: profile.baselineStress),
            checkIns: checkIns.map {
                ExportCheckIn(date: $0.date.shortFormatted,
                              stressLevel: $0.stressLevel,
                              spendingUrge: $0.spendingUrge,
                              sleepQuality: $0.sleepQuality,
                              goalToday: $0.goalToday,
                              note: $0.note,
                              wellnessScore: $0.wellnessScore)
            }
        )
        if let json = try? JSONEncoder().encode(data) {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("equilibrium_export.json")
            try? json.write(to: url)
            exportURL = url
            showShareSheet = true
        }
    }

    func deleteAll(context: ModelContext) {
        try? context.delete(model: AIInsight.self)
        try? context.delete(model: CheckIn.self)
        try? context.delete(model: UserProfile.self)
        try? context.save()
    }
}
