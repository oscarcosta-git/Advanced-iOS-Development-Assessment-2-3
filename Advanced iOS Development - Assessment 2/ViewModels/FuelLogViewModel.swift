import Foundation
import Combine
import CoreData
import WidgetKit

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
    private let sharedDefaults = UserDefaults(suiteName: "group.com.oscarcosta.drivesocial")

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

    func importPendingEntries() {
        let defaults = UserDefaults(suiteName: "group.com.oscarcosta.drivesocial")
        guard let pending = defaults?.array(forKey: "pendingFuelEntries") as? [[String: Any]],
              !pending.isEmpty else { return }

        for dict in pending {
            guard let litres = dict["litres"] as? Double,
                  let price = dict["pricePerLitre"] as? Double,
                  let timestamp = dict["date"] as? Double else { continue }
            let date = Date(timeIntervalSince1970: timestamp)
            let notes = dict["notes"] as? String ?? ""
            let lastOdometer = entries.first?.odometer ?? 0
            try? logUseCase.execute(vehicleID: Self.vehicleID, date: date,
                                    odometer: lastOdometer + 1,
                                    litres: litres, pricePerLitre: price, notes: notes)
        }

        defaults?.removeObject(forKey: "pendingFuelEntries")
        loadEntries()
    }

    private func loadEntries() {
        entries = (try? repository.fetchEntries(for: Self.vehicleID)) ?? []
        stats = statsUseCase.execute(entries: entries)
        writeSharedDefaults()
    }

    private func writeSharedDefaults() {
        guard let last = entries.first else { return }
        sharedDefaults?.set(last.date, forKey: "lastFillDate")
        sharedDefaults?.set(last.litres, forKey: "lastFillLitres")
        sharedDefaults?.set(last.totalCost, forKey: "lastFillCost")
        if let costPerKm = stats?.costPerKm {
            sharedDefaults?.set(costPerKm, forKey: "costPerKm")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "DriveSocialWidget")
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
