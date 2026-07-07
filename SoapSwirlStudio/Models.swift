import Foundation
import SwiftUI

struct SoapSwirlSketchRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var localVisualRef: String
    var domainTags: [String]
    var styleParams: SoapSwirlStyleParams
    var createdAt: Date
    var updatedAt: Date
    var favorite: Bool
}

struct SoapSwirlStyleParams: Codable, Hashable {
    var scentMood: String
    var baseColorHex: String
    var accentColorHex: String
    var swirlIntensity: Double
    var pourStyle: String
    var cutFaceNote: String

    static let defaultPalette = SoapSwirlStyleParams(
        scentMood: "Citrus calm",
        baseColorHex: "F8E7D2",
        accentColorHex: "D9725B",
        swirlIntensity: 0.58,
        pourStyle: "Ribbon pour",
        cutFaceNote: "Creamy loaf with coral ribbons and a soft crescent cut-face."
    )
}

struct StarterExample: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var localAssetName: String
    var disclosureCopy: String

    static let examples: [StarterExample] = [
        StarterExample(
            id: UUID(uuidString: "7AA03277-4F14-40E6-8CCB-FD7E36CDA101")!,
            title: "Citrus Ribbon Loaf",
            localAssetName: "starter-citrus-ribbon",
            disclosureCopy: "Local starter example only. Create your own soap swirl sketch to save real work."
        ),
        StarterExample(
            id: UUID(uuidString: "B7B8A540-CE11-41A5-BC6C-063341113921")!,
            title: "Clay Moon Cut",
            localAssetName: "starter-clay-moon",
            disclosureCopy: "Local starter example only. It never represents an online recipe or service."
        )
    ]
}

struct SoapSwirlDraft: Equatable, Hashable {
    var id: UUID?
    var title: String
    var scentMood: String
    var baseColorHex: String
    var accentColorHex: String
    var swirlIntensity: Double
    var pourStyle: String
    var cutFaceNote: String
    var favorite: Bool

    static let blank = SoapSwirlDraft(
        id: nil,
        title: "",
        scentMood: "Citrus calm",
        baseColorHex: "F8E7D2",
        accentColorHex: "D9725B",
        swirlIntensity: 0.58,
        pourStyle: "Ribbon pour",
        cutFaceNote: "Creamy loaf with coral ribbons and a soft crescent cut-face.",
        favorite: false
    )

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var styleParams: SoapSwirlStyleParams {
        SoapSwirlStyleParams(
            scentMood: scentMood,
            baseColorHex: baseColorHex,
            accentColorHex: accentColorHex,
            swirlIntensity: swirlIntensity,
            pourStyle: pourStyle,
            cutFaceNote: cutFaceNote
        )
    }
}

extension SoapSwirlDraft {
    init(record: SoapSwirlSketchRecord) {
        id = record.id
        title = record.title
        scentMood = record.styleParams.scentMood
        baseColorHex = record.styleParams.baseColorHex
        accentColorHex = record.styleParams.accentColorHex
        swirlIntensity = record.styleParams.swirlIntensity
        pourStyle = record.styleParams.pourStyle
        cutFaceNote = record.styleParams.cutFaceNote
        favorite = record.favorite
    }
}

enum SoapSwirlSaveError: LocalizedError, Equatable {
    case emptyTitle
    case simulatedFailure
    case storageFailure(String)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Name this soap swirl sketch before saving."
        case .simulatedFailure:
            return "Save recovery check stopped the save. Your soap swirl sketch draft is still here."
        case .storageFailure(let message):
            return "The soap swirl sketch could not be saved: \(message)"
        }
    }
}

enum SoapRoute: Hashable {
    case scentSetup
    case sketcher(SoapSwirlDraft)
    case detail(UUID)
    case premium
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
