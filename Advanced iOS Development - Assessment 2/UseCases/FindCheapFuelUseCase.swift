import CoreLocation

struct FindCheapFuelUseCase {
    let repository: FuelStationRepositoryProtocol

    func execute(near location: CLLocation, radiusKm: Double = 5.0) async throws -> [FuelStation] {
        let stations = try await repository.fetchNearby(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radiusKm: radiusKm
        )
        return stations.sorted { $0.pricePerLitre < $1.pricePerLitre }
    }
}
