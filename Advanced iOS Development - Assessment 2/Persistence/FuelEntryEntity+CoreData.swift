import CoreData

@objc(FuelEntryEntity)
public class FuelEntryEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var odometer: Double
    @NSManaged public var litres: Double
    @NSManaged public var pricePerLitre: Double
    @NSManaged public var notes: String?
    @NSManaged public var vehicle: VehicleEntity?
}

extension FuelEntryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FuelEntryEntity> {
        NSFetchRequest<FuelEntryEntity>(entityName: "FuelEntryEntity")
    }

    func toDomain() -> FuelEntry? {
        guard let id, let date else { return nil }
        return FuelEntry(
            id: id,
            date: date,
            odometer: odometer,
            litres: litres,
            pricePerLitre: pricePerLitre,
            notes: notes ?? ""
        )
    }
}
