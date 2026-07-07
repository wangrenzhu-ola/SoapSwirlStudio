import SwiftUI

struct PremiumLocalPacksView: View {
    @EnvironmentObject private var premiumStore: PremiumPackStore

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Premium Local Packs", systemImage: "sparkles.rectangle.stack")
                        .font(.title2.bold())
                    Text("Unlock extra local theme packs for your soap loaf and cut-face previews. Base soap swirl sketch creation is always free.")
                        .foregroundStyle(.secondary)
                    SoapStatusPill(title: premiumStatus, systemImage: "shippingbox")
                }
                .padding(.vertical, 8)
            }

            Section("Included local packs") {
                ForEach(premiumStore.localPacks, id: \.self) { pack in
                    Label(pack, systemImage: "swatchpalette")
                }
            }

            Section("Purchase availability") {
                Text(premiumStore.message)
                    .foregroundStyle(.secondary)
                Button(premiumStore.isPurchasing ? "Unlocking…" : "Unlock premium local packs") {
                    Task { await premiumStore.purchaseLocalPacks() }
                }
                .disabled(premiumStore.isPurchasing)
                .accessibilityLabel("Unlock premium local packs without blocking base soap swirl sketch creation")

                Button("Restore purchases") {
                    Task { await premiumStore.restorePurchases() }
                }

                Button("Preview packs on this device") {
                    premiumStore.unlockForLocalPreview()
                }
                .font(.caption)
            }

            Section {
                Text("No login, backend, cloud sync, or tracking is used. Premium never blocks Scent Color Setup or Swirl Path Sketcher.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .soapScreenBackground()
        .navigationTitle("Premium Local Packs")
        .task { await premiumStore.refreshStoreKitStatus() }
    }

    private var premiumStatus: String {
        switch premiumStore.entitlementState {
        case .unlocked:
            return "Unlocked"
        case .locked:
            return "Base flow free"
        case .storeKitUnavailable:
            return "StoreKit unavailable"
        }
    }
}
