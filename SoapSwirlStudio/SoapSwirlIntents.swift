import AppIntents
import Foundation

struct QuickCaptureSoapSwirlIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Capture Soap Swirl"
    static var description = IntentDescription("Create an editable local soap swirl sketch draft and continue manually in SoapSwirl Studio.")
    static var openAppWhenRun = true

    @Parameter(title: "Sketch Title", default: "Quick soap swirl draft")
    var title: String

    @Parameter(title: "Scent Mood", default: "Siri quick capture")
    var scentMood: String

    func perform() async -> some IntentResult & ProvidesDialog {
        do {
            let savedTitle = try await MainActor.run {
                let store = SoapSwirlStore.intentSharedStore()
                let record = try store.saveIntentDraft(title: title, scentMood: scentMood)
                return record.title
            }
            return .result(dialog: "Created \(savedTitle). Open SoapSwirl Studio to edit the loaf, swirl path, and cut-face preview.")
        } catch {
            return .result(dialog: "Quick capture could not save. Open SoapSwirl Studio and use Scent Color Setup to create the soap swirl sketch manually.")
        }
    }
}

struct SoapSwirlShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickCaptureSoapSwirlIntent(),
            phrases: [
                "Quick capture a soap swirl in \(.applicationName)",
                "Start a soap swirl sketch in \(.applicationName)"
            ],
            shortTitle: "Capture Swirl",
            systemImageName: "scribble.variable"
        )
    }
}
