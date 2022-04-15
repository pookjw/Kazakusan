import SwiftUI

@main
struct KazakusanApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        setDisplayModeButtonVisibilityHidden()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                break
            case .background:
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
