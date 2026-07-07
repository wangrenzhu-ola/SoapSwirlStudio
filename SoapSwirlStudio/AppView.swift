import SwiftUI

struct AppView: View {
    @EnvironmentObject private var store: SoapSwirlStore
    @State private var path: [SoapRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            SwirlWallView(path: $path)
                .navigationDestination(for: SoapRoute.self) { route in
                    switch route {
                    case .scentSetup:
                        ScentColorSetupView(path: $path)
                    case .sketcher(let draft):
                        SwirlPathSketcherView(initialDraft: draft, path: $path)
                    case .detail(let id):
                        SoapSwirlDetailView(recordID: id, path: $path)
                    case .premium:
                        PremiumLocalPacksView()
                    case .legalPrivacy:
                        LegalPrivacyView()
                    }
                }
        }
        .tint(SoapTheme.ink)
    }
}

enum SoapTheme {
    static let butter = Color(hex: "F8E7D2")
    static let coral = Color(hex: "D9725B")
    static let clay = Color(hex: "9C6A57")
    static let ink = Color(hex: "2B211D")
    static let sage = Color(hex: "9DAE91")
}

struct SoapScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [SoapTheme.butter.opacity(0.82), Color(hex: "FFF9EF"), SoapTheme.sage.opacity(0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func soapScreenBackground() -> some View { modifier(SoapScreenBackground()) }
}
