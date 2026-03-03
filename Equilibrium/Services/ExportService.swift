import Foundation

struct ExportService {
    struct ExportData: Encodable {
        struct ProfileExport: Encodable {
            let name: String
            let primaryGoal: String
            let baselineStress: Int
            let createdAt: String
        }
        struct CheckInExport: Encodable {
            let date: String
            let dayKey: String
            let stressLevel: Int
            let spendingUrge: String
            let sleepQuality: Int?
            let goalToday: String
            let note: String?
            let wellnessScore: Int
            let insight: InsightExport?
        }
        struct InsightExport: Encodable {
            let insightText: String
            let actionText: String
            let ifThenText: String
        }
        let exportedAt: String
        let profile: ProfileExport
        let checkIns: [CheckInExport]
    }

    static func buildExportURL(profile: UserProfile, checkIns: [CheckIn]) throws -> URL {
        let fmt = ISO8601DateFormatter()

        let profileExport = ExportData.ProfileExport(
            name: profile.name,
            primaryGoal: profile.primaryGoalRaw,
            baselineStress: profile.baselineStress,
            createdAt: fmt.string(from: profile.createdAt)
        )

        let checkInExports = checkIns.map { ci in
            ExportData.CheckInExport(
                date: fmt.string(from: ci.date),
                dayKey: ci.dayKey,
                stressLevel: ci.stressLevel,
                spendingUrge: ci.spendingUrgeRaw,
                sleepQuality: ci.sleepQuality,
                goalToday: ci.goalTodayRaw,
                note: ci.note,
                wellnessScore: ci.wellnessScore,
                insight: ci.insight.map {
                    ExportData.InsightExport(
                        insightText: $0.insightText,
                        actionText: $0.actionText,
                        ifThenText: $0.ifThenText
                    )
                }
            )
        }

        let export = ExportData(
            exportedAt: fmt.string(from: Date()),
            profile: profileExport,
            checkIns: checkInExports
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(export)

        let timestamp = Int(Date().timeIntervalSince1970)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("equilibrium_export_\(timestamp).json")
        try data.write(to: url)
        return url
    }
}
