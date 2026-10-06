import Foundation

protocol FuelRepositoryProtocol {
    func fetchEntries(for vehicleID: UUID) throws -> [FuelEntry]
    func add(_ entry: FuelEntry, to vehicleID: UUID) throws
    func delete(_ entryID: UUID) throws
}
