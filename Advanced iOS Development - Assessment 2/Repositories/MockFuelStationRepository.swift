import CoreLocation

final class MockFuelStationRepository: FuelStationRepositoryProtocol {
    func fetchNearby(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [FuelStation] {
        // Simulates a short network delay
        try await Task.sleep(nanoseconds: 600_000_000)

        // Sample stations offset around the given coordinate
        let offsets: [(Double, Double, String, String, Double)] = [
            (-0.008,  0.005, "7-Eleven",   "Ultimo",        1.879),
            ( 0.012, -0.003, "Caltex",     "Pyrmont",       1.849),
            (-0.003,  0.018, "BP",         "Surry Hills",   1.919),
            ( 0.021,  0.009, "Shell",      "Newtown",       1.835),
            (-0.015, -0.012, "Ampol",      "Glebe",         1.862),
            ( 0.007,  0.024, "United",     "Redfern",       1.799),
            (-0.022,  0.001, "Coles Express","Chippendale", 1.889),
            ( 0.018, -0.021, "Metro",      "Alexandria",    1.844),
        ]

        return offsets.map { (latOff, lonOff, brand, suburb, price) in
            FuelStation(
                id: UUID(),
                name: "\(brand) \(suburb)",
                brand: brand,
                suburb: suburb,
                coordinate: CLLocationCoordinate2D(
                    latitude: latitude + latOff,
                    longitude: longitude + lonOff
                ),
                pricePerLitre: price,
                lastUpdated: Date().addingTimeInterval(-Double.random(in: 0...3600))
            )
        }
    }
}
