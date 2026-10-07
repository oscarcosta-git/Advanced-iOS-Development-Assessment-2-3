import SwiftUI

@main
struct DriveSocialApp: App {
    @StateObject private var fuelVM = FuelLogViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fuelVM)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        fuelVM.importPendingEntries()
                    }
                }
        }
    }
}
