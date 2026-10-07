import CoreLocation

protocol FuelStationRepositoryProtocol {
    func fetchNearby(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [FuelStation]
}
