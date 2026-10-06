import Foundation

struct CalculateCostPerKmUseCase {
    struct Result {
        let costPerKm: Double      // AUD per km
        let totalSpent: Double     // AUD across all entries
        let totalKm: Double        // km covered across all entries
        let averageLitresPer100km: Double
    }

    func execute(entries: [FuelEntry]) -> Result? {
        guard entries.count >= 2 else { return nil }

        let sorted = entries.sorted { $0.odometer < $1.odometer }
        let totalKm = sorted.last!.odometer - sorted.first!.odometer
        guard totalKm > 0 else { return nil }

        let totalSpent = sorted.dropFirst().reduce(0) { $0 + $1.totalCost }
        let totalLitres = sorted.dropFirst().reduce(0) { $0 + $1.litres }

        return Result(
            costPerKm: totalSpent / totalKm,
            totalSpent: totalSpent,
            totalKm: totalKm,
            averageLitresPer100km: (totalLitres / totalKm) * 100
        )
    }
}
