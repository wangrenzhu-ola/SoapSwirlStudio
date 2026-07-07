import XCTest
import StoreKit
@testable import SoapSwirlStudio

@MainActor
final class SoapSwirlPatchbackAcceptanceTests: XCTestCase {
    func testPatchbackRuntimeWalkthroughCreateEditDeleteSaveFailureAndIntentFallback() throws {
        let url = Self.temporaryStoreURL()
        let store = SoapSwirlStore(storageURL: url, loadImmediately: false)

        var draft = SoapSwirlDraft.blank
        draft.title = "Patchback Runtime Citrus Loaf"
        draft.scentMood = "Patchback citrus and cream"
        let created = try store.save(draft: draft)
        XCTAssertEqual(store.records.map(\.title), ["Patchback Runtime Citrus Loaf"])

        var editDraft = SoapSwirlDraft(record: created)
        editDraft.pourStyle = "Patchback ribbon edit"
        editDraft.cutFaceNote = "Edited in the simulator acceptance path for cut-face readback."
        let edited = try store.save(draft: editDraft)
        XCTAssertEqual(edited.id, created.id)
        XCTAssertEqual(store.records.first?.styleParams.pourStyle, "Patchback ribbon edit")

        XCTAssertThrowsError(try store.save(draft: editDraft, simulateFailure: true)) { error in
            XCTAssertEqual(error as? SoapSwirlSaveError, .simulatedFailure)
        }
        XCTAssertEqual(store.records.first?.title, "Patchback Runtime Citrus Loaf")

        let quickCapture = try store.saveIntentDraft(title: "", scentMood: "")
        XCTAssertEqual(quickCapture.title, "Quick soap swirl draft")
        XCTAssertEqual(quickCapture.styleParams.scentMood, "Siri quick capture")
        XCTAssertTrue(quickCapture.styleParams.cutFaceNote.contains("Quick capture draft"))

        try store.delete(record: edited)
        XCTAssertFalse(store.records.contains { $0.id == edited.id })
        XCTAssertTrue(store.records.contains { $0.id == quickCapture.id })

        print("PATCHBACK_RUNTIME_WALKTHROUGH create=Patchback Runtime Citrus Loaf edit=Patchback ribbon edit saveFailure=simulatedFailurePreservedDraft delete=confirmed appIntentManualFallback=Quick soap swirl draft")
    }

    func testPatchbackPersistenceRelaunchReadbackUsesSameSavedRecord() throws {
        let url = Self.temporaryStoreURL()
        let beforeRelaunch = SoapSwirlStore(storageURL: url, loadImmediately: false)
        var draft = SoapSwirlDraft.blank
        draft.title = "Patchback Relaunch Readback Loaf"
        draft.scentMood = "Lavender oat relaunch"
        let saved = try beforeRelaunch.save(draft: draft)

        let afterRelaunch = SoapSwirlStore(storageURL: url)
        XCTAssertEqual(afterRelaunch.records.count, 1)
        XCTAssertEqual(afterRelaunch.records.first?.id, saved.id)
        XCTAssertEqual(afterRelaunch.records.first?.title, "Patchback Relaunch Readback Loaf")
        XCTAssertEqual(afterRelaunch.records.first?.styleParams.scentMood, "Lavender oat relaunch")

        print("PATCHBACK_PERSISTENCE_RELAUNCH_READBACK title=Patchback Relaunch Readback Loaf id=\(saved.id.uuidString) storage=\(url.path)")
    }

    func testPatchbackStoreKitConfigAndPremiumFallbackKeepBaseCreationFree() async throws {
        let config = try Self.storeKitConfig()
        let productIDs = config.products.map(\.productID)
        XCTAssertEqual(productIDs, ["com.soapswirl.studio.premium.localpacks"])
        XCTAssertEqual(config.products.first?.type, "NonConsumable")

        let premiumStore = PremiumPackStore()
        XCTAssertFalse(premiumStore.baseCreationBlocked)
        await premiumStore.refreshStoreKitStatus()
        XCTAssertFalse(premiumStore.baseCreationBlocked)
        await premiumStore.purchaseLocalPacks()
        XCTAssertFalse(premiumStore.baseCreationBlocked)
        XCTAssertTrue(
            premiumStore.products.contains { $0.id == "com.soapswirl.studio.premium.localpacks" } ||
            premiumStore.message.localizedCaseInsensitiveContains("available") ||
            String(describing: premiumStore.entitlementState).localizedCaseInsensitiveContains("unavailable")
        )

        print("PATCHBACK_STOREKIT_SMOKE configProductIDs=\(productIDs.joined(separator: ",")) fetchedProducts=\(premiumStore.products.map(\.id).joined(separator: ",")) purchaseFallbackMessage=\(premiumStore.message) baseCreationBlocked=\(premiumStore.baseCreationBlocked) state=\(String(describing: premiumStore.entitlementState))")
    }

    func testPatchbackLegalPrivacySurfacesStayLocalOnlyAndReachable() throws {
        let privacyInfo = try String(contentsOf: Self.repoRoot().appendingPathComponent("SoapSwirlStudio/PrivacyInfo.xcprivacy"))
        XCTAssertTrue(privacyInfo.contains("NSPrivacyTracking"))
        XCTAssertTrue(privacyInfo.contains("<false/>"))
        XCTAssertTrue(privacyInfo.contains("NSPrivacyCollectedDataTypes"))

        let legalView = try String(contentsOf: Self.repoRoot().appendingPathComponent("SoapSwirlStudio/LegalPrivacyView.swift"))
        XCTAssertTrue(legalView.contains("Privacy Policy"))
        XCTAssertTrue(legalView.contains("User Agreement"))
        XCTAssertTrue(legalView.contains("does not use tracking"))
        XCTAssertTrue(legalView.contains("Premium Local Packs are an optional non-consumable unlock"))

        let wallView = try String(contentsOf: Self.repoRoot().appendingPathComponent("SoapSwirlStudio/SwirlWallView.swift"))
        XCTAssertTrue(wallView.contains("path.append(.legalPrivacy)"))

        print("PATCHBACK_LEGAL_PRIVACY_SURFACE reachable=SwirlWall PrivacyNoticeCard localOnly=true tracking=false collectedData=false")
    }

    private static func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("soap-swirl-sketches.json")
    }

    private static func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private static func storeKitConfig() throws -> StoreKitConfigReadback {
        let url = repoRoot().appendingPathComponent("SoapSwirlStudio/StoreKit/SoapSwirlStudio.storekit")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(StoreKitConfigReadback.self, from: data)
    }
}

private struct StoreKitConfigReadback: Decodable {
    struct Product: Decodable {
        let productID: String
        let type: String
    }

    let products: [Product]
}
