import XCTest
@testable import SoapSwirlStudio

@MainActor
final class SoapSwirlStoreTests: XCTestCase {
    func testCreatePersistReloadEditDeleteSoapSwirlSketch() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
        let store = SoapSwirlStore(storageURL: url, loadImmediately: false)
        var draft = SoapSwirlDraft.blank
        draft.title = "Cedar Citrus Test Loaf"
        draft.scentMood = "Cedar citrus"

        let saved = try store.save(draft: draft)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(saved.title, "Cedar Citrus Test Loaf")

        let reloaded = SoapSwirlStore(storageURL: url)
        XCTAssertEqual(reloaded.records.map(\.title), ["Cedar Citrus Test Loaf"])

        var editDraft = SoapSwirlDraft(record: saved)
        editDraft.cutFaceNote = "Edited cut-face preview with a bolder ribbon."
        let edited = try reloaded.save(draft: editDraft)
        XCTAssertEqual(edited.id, saved.id)
        XCTAssertLessThanOrEqual(edited.createdAt, edited.updatedAt)
        XCTAssertEqual(reloaded.records.first?.styleParams.cutFaceNote, "Edited cut-face preview with a bolder ribbon.")

        try reloaded.delete(record: edited)
        XCTAssertTrue(reloaded.records.isEmpty)
    }

    func testSimulatedSaveFailurePreservesExistingRecords() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
        let store = SoapSwirlStore(storageURL: url, loadImmediately: false)
        var draft = SoapSwirlDraft.blank
        draft.title = "Failure Keeps Draft"

        XCTAssertThrowsError(try store.save(draft: draft, simulateFailure: true)) { error in
            XCTAssertEqual(error as? SoapSwirlSaveError, .simulatedFailure)
        }
        XCTAssertTrue(store.records.isEmpty)
        XCTAssertEqual(draft.title, "Failure Keeps Draft")
    }

    func testIntentDraftUsesManualFallbackDefaults() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
        let store = SoapSwirlStore(storageURL: url, loadImmediately: false)
        let record = try store.saveIntentDraft(title: "", scentMood: "")
        XCTAssertEqual(record.title, "Quick soap swirl draft")
        XCTAssertEqual(record.styleParams.scentMood, "Siri quick capture")
        XCTAssertTrue(record.styleParams.cutFaceNote.contains("Quick capture draft"))
    }

    func testReadFailureProtectsExistingFileFromOverwrite() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not-json".utf8).write(to: url)

        let store = SoapSwirlStore(storageURL: url)
        var draft = SoapSwirlDraft.blank
        draft.title = "Protected Draft"

        XCTAssertThrowsError(try store.save(draft: draft)) { error in
            XCTAssertTrue(String(describing: error).contains("storageFailure"))
        }
        XCTAssertEqual(try String(contentsOf: url), "not-json")
    }

    func testVisualReferenceIsDeterministic() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
        let store = SoapSwirlStore(storageURL: url, loadImmediately: false)
        var draft = SoapSwirlDraft.blank
        draft.title = "Stable Visual"
        let first = try store.save(draft: draft).localVisualRef
        draft.id = nil
        let second = try store.save(draft: draft).localVisualRef
        XCTAssertEqual(first, second)
    }

}

@MainActor
final class SoapPourPatternTests: XCTestCase {
    func testPourStyleNamesMapToDistinctVisualPatterns() {
        XCTAssertEqual(SoapPourPattern.pattern(for: "Ribbon pour"), .ribbonPour)
        XCTAssertEqual(SoapPourPattern.pattern(for: "Moon comb pull"), .moonComb)
        XCTAssertEqual(SoapPourPattern.pattern(for: "Drop swirl"), .dropSwirl)
        XCTAssertEqual(SoapPourPattern.pattern(for: "In-the-pot swirl"), .inThePot)
        XCTAssertEqual(SoapPourPattern.pattern(for: "marble pot blend"), .inThePot)
    }

    func testAllPourPatternsExposeUserReadableVisualSummaries() {
        let summaries = SoapPourPattern.allCases.map(\.accessibilitySummary)
        XCTAssertEqual(Set(summaries).count, SoapPourPattern.allCases.count)
        XCTAssertTrue(summaries.contains("long flowing ribbon bands"))
        XCTAssertTrue(summaries.contains("curved crescent comb arcs"))
        XCTAssertTrue(summaries.contains("scattered drop swirl circles"))
        XCTAssertTrue(summaries.contains("marbled in-the-pot waves"))
    }
}
