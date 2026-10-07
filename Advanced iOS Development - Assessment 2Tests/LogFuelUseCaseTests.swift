import Testing
@testable import Advanced_iOS_Development___Assessment_2

@Suite("LogFuelUseCase")
@MainActor
struct LogFuelUseCaseTests {
    let vehicleID = FuelLogViewModel.vehicleID

    @Test("rejects fill-up with zero litres")
    func rejectsZeroLitres() throws {
        let repo = MockFuelRepository()
        let useCase = LogFuelUseCase(repository: repo)
        #expect(throws: LogFuelUseCase.FuelError.negativeLitres) {
            try useCase.execute(vehicleID: vehicleID, date: .now,
                                odometer: 1000, litres: 0,
                                pricePerLitre: 1.85, notes: "")
        }
    }

    @Test("rejects fill-up with zero price per litre")
    func rejectsZeroPrice() throws {
        let repo = MockFuelRepository()
        let useCase = LogFuelUseCase(repository: repo)
        #expect(throws: LogFuelUseCase.FuelError.negativePrice) {
            try useCase.execute(vehicleID: vehicleID, date: .now,
                                odometer: 1000, litres: 40,
                                pricePerLitre: 0, notes: "")
        }
    }

    @Test("rejects odometer lower than previous entry")
    func rejectsDecreasingOdometer() throws {
        let repo = MockFuelRepository()
        let useCase = LogFuelUseCase(repository: repo)
        // Add first entry at 50,000 km
        try useCase.execute(vehicleID: vehicleID, date: .now,
                            odometer: 50_000, litres: 40,
                            pricePerLitre: 1.85, notes: "")
        // Try to add second entry at lower odometer
        #expect(throws: LogFuelUseCase.FuelError.self) {
            try useCase.execute(vehicleID: vehicleID, date: .now,
                                odometer: 49_000, litres: 38,
                                pricePerLitre: 1.89, notes: "")
        }
    }

    @Test("saves valid fill-up to repository")
    func savesValidFillUp() throws {
        let repo = MockFuelRepository()
        let useCase = LogFuelUseCase(repository: repo)
        try useCase.execute(vehicleID: vehicleID, date: .now,
                            odometer: 42_000, litres: 45,
                            pricePerLitre: 1.92, notes: "Highway")
        let entries = try repo.fetchEntries(for: vehicleID)
        #expect(entries.count == 1)
        #expect(entries[0].litres == 45)
        #expect(entries[0].pricePerLitre == 1.92)
    }

    @Test("allows sequential fill-ups with increasing odometer")
    func allowsSequentialFillUps() throws {
        let repo = MockFuelRepository()
        let useCase = LogFuelUseCase(repository: repo)
        try useCase.execute(vehicleID: vehicleID, date: .now,
                            odometer: 40_000, litres: 40,
                            pricePerLitre: 1.85, notes: "")
        try useCase.execute(vehicleID: vehicleID, date: .now,
                            odometer: 40_500, litres: 38,
                            pricePerLitre: 1.89, notes: "")
        let entries = try repo.fetchEntries(for: vehicleID)
        #expect(entries.count == 2)
    }
}
