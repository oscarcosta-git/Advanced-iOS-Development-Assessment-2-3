import Testing
@testable import Advanced_iOS_Development___Assessment_2

@Suite("CalculateCostPerKmUseCase")
struct CalculateCostPerKmUseCaseTests {
    let useCase = CalculateCostPerKmUseCase()

    @Test("returns nil when fewer than two fill-ups exist")
    func returnsNilWithSingleEntry() {
        let entries = [
            FuelEntry(id: .init(), date: .now, odometer: 40_000,
                      litres: 40, pricePerLitre: 1.85, notes: "")
        ]
        #expect(useCase.execute(entries: entries) == nil)
    }

    @Test("returns nil for empty fill-up list")
    func returnsNilForEmpty() {
        #expect(useCase.execute(entries: []) == nil)
    }

    @Test("calculates cost per km correctly across two fill-ups")
    func calculatesCostPerKm() {
        let entries = [
            FuelEntry(id: .init(), date: .now.addingTimeInterval(-86400),
                      odometer: 40_000, litres: 40, pricePerLitre: 1.80, notes: ""),
            FuelEntry(id: .init(), date: .now,
                      odometer: 40_500, litres: 38, pricePerLitre: 1.90, notes: "")
        ]
        let result = useCase.execute(entries: entries)
        #expect(result != nil)
        // 38 * 1.90 = 72.20 over 500 km = $0.1444/km
        #expect(abs((result?.costPerKm ?? 0) - 0.1444) < 0.001)
    }

    @Test("calculates litres per 100 km correctly")
    func calculatesLitresPer100km() {
        let entries = [
            FuelEntry(id: .init(), date: .now.addingTimeInterval(-86400),
                      odometer: 40_000, litres: 40, pricePerLitre: 1.80, notes: ""),
            FuelEntry(id: .init(), date: .now,
                      odometer: 40_500, litres: 38, pricePerLitre: 1.90, notes: "")
        ]
        let result = useCase.execute(entries: entries)
        // 38L over 500km = 7.6 L/100km
        #expect(abs((result?.averageLitresPer100km ?? 0) - 7.6) < 0.01)
    }

    @Test("totals spend across all fill-ups except the first odometer baseline")
    func totalsSpenCorrectly() {
        let entries = [
            FuelEntry(id: .init(), date: .now.addingTimeInterval(-86400 * 2),
                      odometer: 40_000, litres: 40, pricePerLitre: 1.80, notes: ""),
            FuelEntry(id: .init(), date: .now.addingTimeInterval(-86400),
                      odometer: 40_500, litres: 38, pricePerLitre: 1.90, notes: ""),
            FuelEntry(id: .init(), date: .now,
                      odometer: 41_000, litres: 42, pricePerLitre: 1.85, notes: "")
        ]
        let result = useCase.execute(entries: entries)
        // 38*1.90 + 42*1.85 = 72.20 + 77.70 = 149.90
        #expect(abs((result?.totalSpent ?? 0) - 149.90) < 0.01)
    }
}
