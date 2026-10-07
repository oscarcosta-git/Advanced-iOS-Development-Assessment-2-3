import CoreLocation

struct FuelStation: Identifiable {
    let id: UUID
    let name: String
    let brand: String
    let suburb: String
    let coordinate: CLLocationCoordinate2D
    let pricePerLitre: Double
    let lastUpdated: Date

    var formattedPrice: String { String(format: "$%.3f", pricePerLitre) }
}
