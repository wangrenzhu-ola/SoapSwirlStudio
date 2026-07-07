import Foundation
import Combine
import StoreKit

@MainActor
final class PremiumPackStore: ObservableObject {
    enum EntitlementState: Equatable {
        case unlocked
        case locked
        case storeKitUnavailable(String)
    }

    @Published private(set) var entitlementState: EntitlementState = .locked
    @Published private(set) var message = "Base soap swirl sketch creation is free. Premium only adds local visual packs."
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchasing = false

    let productIDs = ["com.soapswirl.studio.premium.localpacks"]
    let localPacks = ["Botanical Mica", "Clay Moon", "Citrus Ribbon"]

    var baseCreationBlocked: Bool { false }

    func refreshStoreKitStatus() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            products = fetchedProducts
            if fetchedProducts.isEmpty {
                entitlementState = .storeKitUnavailable("Purchases are not available on this device. Manual sketch creation remains available.")
            } else {
                message = "Premium local packs are ready when you choose to unlock them."
            }
        } catch {
            entitlementState = .storeKitUnavailable("Purchases are not available right now. Manual sketch creation remains available.")
        }
    }

    func purchaseLocalPacks() async {
        isPurchasing = true
        defer { isPurchasing = false }
        guard let product = products.first else {
            entitlementState = .storeKitUnavailable("Purchases are not available on this device. Manual sketch creation remains available.")
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    entitlementState = .unlocked
                    message = "Premium local packs unlocked."
                    await transaction.finish()
                case .unverified:
                    message = "The purchase could not be verified. Your base soap swirl sketch flow is unchanged."
                }
            case .userCancelled:
                message = "Purchase cancelled. You can keep creating soap swirl sketches for free."
            case .pending:
                message = "Purchase pending. Base sketch creation remains available."
            @unknown default:
                message = "Purchase status changed. Base sketch creation remains available."
            }
        } catch {
            message = "Purchase failed. Base sketch creation remains available."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            message = "Restore checked. Base sketch creation remains available."
        } catch {
            message = "Restore is unavailable right now. Base sketch creation remains available."
        }
    }

    func unlockForLocalPreview() {
        entitlementState = .unlocked
        message = "Local preview packs unlocked for this device preview."
    }
}
