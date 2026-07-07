import Foundation
import Combine

@MainActor
final class SoapSwirlStore: ObservableObject {
    @Published private(set) var records: [SoapSwirlSketchRecord] = []
    @Published var lastSaveMessage: String?

    private let storageURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var writeBlockedByReadFailure = false

    init(storageURL: URL? = nil, loadImmediately: Bool = true) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if loadImmediately {
            load()
        }
    }

    static func defaultStorageURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("SoapSwirlStudio", isDirectory: true).appendingPathComponent("soap-swirl-sketches.json")
    }

    static func intentSharedStore() -> SoapSwirlStore {
        SoapSwirlStore()
    }

    func load() {
        writeBlockedByReadFailure = false
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            records = []
            return
        }
        do {
            let data = try Data(contentsOf: storageURL)
            records = try decoder.decode([SoapSwirlSketchRecord].self, from: data).sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            lastSaveMessage = "Local readback failed, so the existing file is protected from overwrite. Export or remove the damaged file before saving new sketches."
            writeBlockedByReadFailure = true
            records = []
        }
    }

    @discardableResult
    func save(draft: SoapSwirlDraft, simulateFailure: Bool = false) throws -> SoapSwirlSketchRecord {
        guard !draft.trimmedTitle.isEmpty else { throw SoapSwirlSaveError.emptyTitle }
        guard !simulateFailure else { throw SoapSwirlSaveError.simulatedFailure }
        try ensureCanWrite()

        let now = Date()
        var record = SoapSwirlSketchRecord(
            id: draft.id ?? UUID(),
            title: draft.trimmedTitle,
            localVisualRef: visualRef(for: draft),
            domainTags: [draft.scentMood, draft.pourStyle, "soap swirl sketch"],
            styleParams: draft.styleParams,
            createdAt: now,
            updatedAt: now,
            favorite: draft.favorite
        )

        var nextRecords = records
        if let index = nextRecords.firstIndex(where: { $0.id == record.id }) {
            record.createdAt = nextRecords[index].createdAt
            nextRecords[index] = record
        } else {
            nextRecords.insert(record, at: 0)
        }

        nextRecords.sort { $0.updatedAt > $1.updatedAt }
        try persist(nextRecords)
        records = nextRecords
        lastSaveMessage = "Soap swirl sketch saved."
        return record
    }

    func delete(record: SoapSwirlSketchRecord) throws {
        try ensureCanWrite()
        let nextRecords = records.filter { $0.id != record.id }
        try persist(nextRecords)
        records = nextRecords
        lastSaveMessage = "Deleted \"\(record.title)\" from the Swirl Wall."
    }

    func toggleFavorite(record: SoapSwirlSketchRecord) throws {
        try ensureCanWrite()
        var nextRecords = records
        guard let index = nextRecords.firstIndex(where: { $0.id == record.id }) else { return }
        nextRecords[index].favorite.toggle()
        nextRecords[index].updatedAt = Date()
        try persist(nextRecords)
        records = nextRecords
    }

    func saveIntentDraft(title: String, scentMood: String) throws -> SoapSwirlSketchRecord {
        var draft = SoapSwirlDraft.blank
        draft.title = title.isEmpty ? "Quick soap swirl draft" : title
        draft.scentMood = scentMood.isEmpty ? "Siri quick capture" : scentMood
        draft.cutFaceNote = "Quick capture draft. Open SoapSwirl Studio to tune the loaf, swirl path, and cut-face preview."
        return try save(draft: draft)
    }

    private func ensureCanWrite() throws {
        if writeBlockedByReadFailure && FileManager.default.fileExists(atPath: storageURL.path) {
            throw SoapSwirlSaveError.storageFailure("Local readback failed, so this file is protected from overwrite.")
        }
    }

    private func persist(_ nextRecords: [SoapSwirlSketchRecord]) throws {
        do {
            try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try encoder.encode(nextRecords)
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            throw SoapSwirlSaveError.storageFailure(error.localizedDescription)
        }
    }

    private func visualRef(for draft: SoapSwirlDraft) -> String {
        let seed = [draft.baseColorHex, draft.accentColorHex, draft.pourStyle].joined(separator: "-")
        return "local-loaf-\(Self.stableHash(seed))"
    }

    private static func stableHash(_ value: String) -> String {
        var hash: UInt64 = 1469598103934665603
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return String(hash, radix: 16)
    }
}
