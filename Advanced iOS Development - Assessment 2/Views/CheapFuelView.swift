import SwiftUI
import MapKit

struct CheapFuelView: View {
    @StateObject private var vm = CheapFuelViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(coordinateRegion: $vm.region, annotationItems: vm.stations) { station in
                    MapAnnotation(coordinate: station.coordinate) {
                        StationMapPin(station: station, isCheapest: station.id == vm.stations.first?.id)
                    }
                }
                .frame(height: 280)

                if vm.isLoading {
                    ProgressView("Finding stations...")
                        .padding()
                    Spacer()
                } else if vm.stations.isEmpty {
                    ContentUnavailableView(
                        "No stations found",
                        systemImage: "fuelpump.slash",
                        description: Text("Tap Search to find fuel stations near you.")
                    )
                } else {
                    List {
                        Section("Sorted by price — cheapest first") {
                            ForEach(Array(vm.stations.enumerated()), id: \.element.id) { index, station in
                                StationRow(station: station, rank: index + 1)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Cheap Fuel Nearby")
            .toolbar {
                Button {
                    vm.requestLocation()
                } label: {
                    Label("Search", systemImage: "location.fill")
                }
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
            .onAppear {
                vm.requestLocation()
            }
        }
    }
}

private struct StationMapPin: View {
    let station: FuelStation
    let isCheapest: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(station.formattedPrice)
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(isCheapest ? Color.green : Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            Image(systemName: "triangle.fill")
                .font(.system(size: 6))
                .foregroundStyle(isCheapest ? .green : .blue)
                .rotationEffect(.degrees(180))
        }
    }
}

private struct StationRow: View {
    let station: FuelStation
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline)
                .foregroundStyle(rank == 1 ? .green : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.subheadline.bold())
                Text(station.suburb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(station.formattedPrice)
                    .font(.headline)
                    .foregroundStyle(rank == 1 ? .green : .primary)
                Text(station.lastUpdated.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CheapFuelView()
}
