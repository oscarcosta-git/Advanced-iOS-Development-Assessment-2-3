import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TripDashboardView()
                .tabItem { Label("Trips", systemImage: "car.fill") }
            LeaderboardView()
                .tabItem { Label("Leaderboard", systemImage: "trophy.fill") }
            MyCarView()
                .tabItem { Label("My Car", systemImage: "wrench.and.screwdriver.fill") }
            FindMechanicView()
                .tabItem { Label("Find Mechanic", systemImage: "magnifyingglass") }
            FuelLogView()
                .tabItem { Label("Fuel Log", systemImage: "fuelpump.fill") }
        }
    }
}

#Preview {
    ContentView()
}
