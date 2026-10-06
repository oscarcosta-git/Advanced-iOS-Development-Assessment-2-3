import Foundation

struct FuelEntry: Identifiable {
    let id: UUID
    let date: Date
    let odometer: Double       // km at time of fill
    let litres: Double         // litres added
    let pricePerLitre: Double  // AUD per litre
    let notes: String

    var totalCost: Double { litres * pricePerLitre }

    static let samples: [FuelEntry] = [
        FuelEntry(id: UUID(), date: Date().addingTimeInterval(-86400 * 14),
                  odometer: 41_500, litres: 45.2, pricePerLitre: 1.89, notes: ""),
        FuelEntry(id: UUID(), date: Date().addingTimeInterval(-86400 * 7),
                  odometer: 42_100, litres: 38.7, pricePerLitre: 1.92, notes: "Highway run"),
        FuelEntry(id: UUID(), date: Date().addingTimeInterval(-86400 * 1),
                  odometer: 42_600, litres: 41.0, pricePerLitre: 1.85, notes: "")
    ]
}
