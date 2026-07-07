import SwiftUI

@main
struct SoapSwirlStudioApp: App {
    @StateObject private var store = SoapSwirlStore()
    @StateObject private var premiumStore = PremiumPackStore()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(store)
                .environmentObject(premiumStore)
        }
    }
}
