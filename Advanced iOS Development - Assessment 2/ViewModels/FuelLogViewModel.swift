import Foundation
import Combine
import CoreData

class FuelLogViewModel: ObservableObject {
    @Published var entries: [FuelEntry] = []
    @Published var stats: CalculateCostPerKmUseCase.Result?
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var showAddFuel: Bool = false

    // Fixed vehicle ID for the single-vehicle app
    static let vehicleID = UUID(uuidString: "A1B2C3D4-0000-0000-0000-000000000001")!

    private let repository: FuelRepositoryProtocol
    private let logUseCase: LogFuelUseCase
    private let statsUseCase = CalculateCostPerKmUseCase()

    init(repository: FuelRepositoryProtocol = CoreDataFuelRepository()) {
        self.repository = repository
        self.logUseCase = LogFuelUseCase(repository: repository)
        ensureVehicleExists()
        loadEntries()
    }

    func addFuel(date: Date, odometer: Double, litres: Double, pricePerLitre: Double, notes: String) {
        do {
            try logUseCase.execute(vehicleID: Self.vehicleID, date: date,
                                   odometer: odometer, litres: litres,
                                   pricePerLitre: pricePerLitre, notes: notes)
            loadEntries()
            showAddFuel = false
        } catch let error as LogFuelUseCase.FuelError {
            errorMessage = error.localizedDescription
            showError = true
        } catch { }
    }

    func delete(entry: FuelEntry) {
        try? repository.delete(entry.id)
        loadEntries()
    }

    private func loadEntries() {
        entries = (try? repository.fetchEntries(for: Self.vehicleID)) ?? []
        stats = statsUseCase.execute(entries: entries)
    }

    private func ensureVehicleExists() {
        let context = PersistenceController.shared.container.viewContext
        let request = VehicleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", Self.vehicleID as CVarArg)
        request.fetchLimit = 1
        guard (try? context.fetch(request))?.isEmpty != false else { return }

        let vehicle = VehicleEntity(context: context)
        vehicle.id = Self.vehicleID
        vehicle.make = Vehicle.sample.make
        vehicle.model = Vehicle.sample.model
        vehicle.year = Int32(Vehicle.sample.year)
        vehicle.plate = Vehicle.sample.plate
        try? context.save()
    }
}
