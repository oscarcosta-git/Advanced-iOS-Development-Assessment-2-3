import Foundation
import CoreLocation
import Combine
import MapKit

@MainActor
class CheapFuelViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var stations: [FuelStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), // Sydney fallback
        latitudinalMeters: 8000,
        longitudinalMeters: 8000
    )

    private let locationManager = CLLocationManager()
    private let useCase: FindCheapFuelUseCase

    init(repository: FuelStationRepositoryProtocol = MockFuelStationRepository()) {
        self.useCase = FindCheapFuelUseCase(repository: repository)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            fetchStations(near: CLLocation(latitude: region.center.latitude,
                                           longitude: region.center.longitude))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        region = MKCoordinateRegion(center: location.coordinate,
                                    latitudinalMeters: 8000,
                                    longitudinalMeters: 8000)
        fetchStations(near: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fetchStations(near: CLLocation(latitude: region.center.latitude,
                                       longitude: region.center.longitude))
    }

    private func fetchStations(near location: CLLocation) {
        isLoading = true
        Task {
            do {
                stations = try await useCase.execute(near: location)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}
