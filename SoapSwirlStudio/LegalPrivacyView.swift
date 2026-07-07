import SwiftUI

struct LegalPrivacyView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Privacy Policy", systemImage: "lock.shield")
                        .font(.title2.bold())
                    Text("SoapSwirl Studio stores soap swirl sketches only on this device as local JSON. The app does not use tracking, analytics, ads, backend accounts, cloud sync, camera, photos, microphone, contacts, or location.")
                        .foregroundStyle(.secondary)
                    SoapStatusPill(title: "No tracking", systemImage: "hand.raised")
                    SoapStatusPill(title: "No collected data", systemImage: "tray")
                }
                .padding(.vertical, 8)
            }

            Section("Local data") {
                Text("Saved sketch titles, scent notes, color choices, swirl intensity, pour style, cut-face notes, favorites, and generated local visual references remain in the app container on this device.")
                Text("Deleting a soap swirl sketch removes that saved record from the local Swirl Wall. Uninstalling the app removes its local app-container data according to iOS behavior.")
                Text("Starter examples and Premium local pack names are bundled/local metadata, not online recipes or remote service content.")
            }

            Section("User Agreement") {
                Text("Use SoapSwirl Studio as a creative planning tool for handmade soap visuals. Review real ingredients, safety, curing, and labeling requirements outside the app before making or selling soap.")
                Text("Premium Local Packs are an optional non-consumable unlock for extra local visual themes. Scent Color Setup, Swirl Path Sketcher, saving, editing, deleting, and manual App Intent fallback remain free.")
                Text("This app provides local creative notes and previews only; it does not provide professional, medical, legal, or manufacturing advice.")
            }

            Section("Support") {
                Text("For App Store metadata, list Privacy Policy and User Agreement as in-app legal surfaces reachable from the Swirl Wall privacy note. Locale: en-US. Bundle ID: com.soapswirl.studio.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .soapScreenBackground()
        .navigationTitle("Privacy & Terms")
    }
}
