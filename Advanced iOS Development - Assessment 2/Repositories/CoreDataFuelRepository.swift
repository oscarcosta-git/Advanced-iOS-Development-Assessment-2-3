import CoreData
import Foundation

final class CoreDataFuelRepository: FuelRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchEntries(for vehicleID: UUID) throws -> [FuelEntry] {
        let request = FuelEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "vehicle.id == %@", vehicleID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try context.fetch(request).compactMap { $0.toDomain() }
    }

    func add(_ entry: FuelEntry, to vehicleID: UUID) throws {
        let vehicleRequest = VehicleEntity.fetchRequest()
        vehicleRequest.predicate = NSPredicate(format: "id == %@", vehicleID as CVarArg)
        vehicleRequest.fetchLimit = 1

        guard let vehicle = try context.fetch(vehicleRequest).first else { return }

        let entity = FuelEntryEntity(context: context)
        entity.id = entry.id
        entity.date = entry.date
        entity.odometer = entry.odometer
        entity.litres = entry.litres
        entity.pricePerLitre = entry.pricePerLitre
        entity.notes = entry.notes
        entity.vehicle = vehicle

        try context.save()
    }

    func delete(_ entryID: UUID) throws {
        let request = FuelEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entryID as CVarArg)
        request.fetchLimit = 1

        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}
