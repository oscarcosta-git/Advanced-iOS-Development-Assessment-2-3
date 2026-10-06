import CoreData

@objc(VehicleEntity)
public class VehicleEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var year: Int32
    @NSManaged public var plate: String?
    @NSManaged public var fuelEntries: NSSet?
}

extension VehicleEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VehicleEntity> {
        NSFetchRequest<VehicleEntity>(entityName: "VehicleEntity")
    }
}
