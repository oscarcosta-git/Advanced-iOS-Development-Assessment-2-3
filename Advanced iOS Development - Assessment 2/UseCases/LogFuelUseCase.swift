import Foundation

struct LogFuelUseCase {
    enum FuelError: LocalizedError {
        case negativeLitres
        case negativePrice
        case odometerLowerThanPrevious(last: Double)

        var errorDescription: String? {
            switch self {
            case .negativeLitres:
                return "Litres filled must be greater than zero."
            case .negativePrice:
                return "Price per litre must be greater than zero."
            case .odometerLowerThanPrevious(let last):
                return "Odometer reading must be higher than the previous entry (\(Int(last)) km)."
            }
        }
    }

    let repository: FuelRepositoryProtocol

    func execute(vehicleID: UUID, date: Date, odometer: Double, litres: Double, pricePerLitre: Double, notes: String) throws {
        guard litres > 0 else { throw FuelError.negativeLitres }
        guard pricePerLitre > 0 else { throw FuelError.negativePrice }

        let existing = try repository.fetchEntries(for: vehicleID)
        if let lastOdometer = existing.first.map({ $0.odometer }), odometer <= lastOdometer {
            throw FuelError.odometerLowerThanPrevious(last: lastOdometer)
        }

        let entry = FuelEntry(id: UUID(), date: date, odometer: odometer,
                              litres: litres, pricePerLitre: pricePerLitre, notes: notes)
        try repository.add(entry, to: vehicleID)
    }
}
