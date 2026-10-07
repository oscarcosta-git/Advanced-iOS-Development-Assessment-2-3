import SwiftUI

struct FuelLogView: View {
    @EnvironmentObject private var vm: FuelLogViewModel

    var body: some View {
        NavigationStack {
            List {
                if let stats = vm.stats {
                    Section("Running Costs") {
                        HStack {
                            StatTile(label: "Cost / km", value: String(format: "$%.2f", stats.costPerKm))
                            Divider()
                            StatTile(label: "L / 100 km", value: String(format: "%.1f L", stats.averageLitresPer100km))
                            Divider()
                            StatTile(label: "Total spent", value: String(format: "$%.0f", stats.totalSpent))
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Fill-ups") {
                    if vm.entries.isEmpty {
                        ContentUnavailableView(
                            "No fill-ups yet",
                            systemImage: "fuelpump",
                            description: Text("Tap Add Fill-up to log your first entry.")
                        )
                    } else {
                        ForEach(vm.entries) { entry in
                            FuelEntryRow(entry: entry)
                        }
                        .onDelete { offsets in
                            offsets.forEach { vm.delete(entry: vm.entries[$0]) }
                        }
                    }
                }
            }
            .navigationTitle("Fuel Log")
            .toolbar {
                Button("Add Fill-up") {
                    vm.showAddFuel = true
                }
            }
            .sheet(isPresented: $vm.showAddFuel) {
                AddFuelView(vm: vm)
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
        }
    }
}

private struct StatTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FuelEntryRow: View {
    let entry: FuelEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(format: "%.1f L", entry.litres))
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", entry.totalCost))
                    .font(.headline)
                    .foregroundStyle(.green)
            }
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                Text("·")
                Text(String(format: "%.0f km", entry.odometer))
                Text("·")
                Text(String(format: "$%.3f/L", entry.pricePerLitre))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct AddFuelView: View {
    @ObservedObject var vm: FuelLogViewModel
    @Environment(\.dismiss) var dismiss

    @State private var date: Date = Date()
    @State private var odometer: String = ""
    @State private var litres: String = ""
    @State private var pricePerLitre: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Fill-up details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Odometer (km)", text: $odometer)
                        .keyboardType(.decimalPad)
                    TextField("Litres added", text: $litres)
                        .keyboardType(.decimalPad)
                    TextField("Price per litre (AUD)", text: $pricePerLitre)
                        .keyboardType(.decimalPad)
                }
                Section("Notes (optional)") {
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Add Fill-up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let odo = Double(odometer),
                              let l = Double(litres),
                              let price = Double(pricePerLitre) else { return }
                        vm.addFuel(date: date, odometer: odo, litres: l,
                                   pricePerLitre: price, notes: notes)
                    }
                }
            }
        }
    }
}

#Preview {
    FuelLogView()
        .environmentObject(FuelLogViewModel())
}
