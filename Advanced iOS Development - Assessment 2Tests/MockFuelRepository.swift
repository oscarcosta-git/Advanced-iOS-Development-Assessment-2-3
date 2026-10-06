import Foundation
@testable import Advanced_iOS_Development___Assessment_2

final class MockFuelRepository: FuelRepositoryProtocol {
    var entries: [UUID: [FuelEntry]] = [:]
    var shouldThrow: Error?

    func fetchEntries(for vehicleID: UUID) throws -> [FuelEntry] {
        if let error = shouldThrow { throw error }
        return entries[vehicleID] ?? []
    }

    func add(_ entry: FuelEntry, to vehicleID: UUID) throws {
        if let error = shouldThrow { throw error }
        entries[vehicleID, default: []].append(entry)
    }

    func delete(_ entryID: UUID) throws {
        if let error = shouldThrow { throw error }
        for key in entries.keys {
            entries[key]?.removeAll { $0.id == entryID }
        }
    }
}
