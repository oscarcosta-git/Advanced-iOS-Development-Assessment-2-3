import WidgetKit
import SwiftUI

private let appGroupID = "group.com.oscarcosta.drivesocial"

struct FuelWidgetEntry: TimelineEntry {
    let date: Date
    let lastFillDate: Date?
    let lastFillLitres: Double
    let lastFillCost: Double
    let costPerKm: Double?

    static let placeholder = FuelWidgetEntry(
        date: Date(),
        lastFillDate: Date(),
        lastFillLitres: 42.5,
        lastFillCost: 80.33,
        costPerKm: 0.18
    )
}

struct FuelWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FuelWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FuelWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FuelWidgetEntry>) -> Void) {
        let entry = readEntry()
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func readEntry() -> FuelWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let lastFillDate = defaults?.object(forKey: "lastFillDate") as? Date
        let lastFillLitres = defaults?.double(forKey: "lastFillLitres") ?? 0
        let lastFillCost = defaults?.double(forKey: "lastFillCost") ?? 0
        let costPerKm = defaults?.object(forKey: "costPerKm") as? Double

        return FuelWidgetEntry(
            date: Date(),
            lastFillDate: lastFillDate,
            lastFillLitres: lastFillLitres,
            lastFillCost: lastFillCost,
            costPerKm: costPerKm
        )
    }
}

struct DriveSocialWidgetEntryView: View {
    var entry: FuelWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.lastFillDate == nil {
            noDataView
        } else {
            dataView
        }
    }

    private var noDataView: some View {
        VStack(spacing: 4) {
            Image(systemName: "fuelpump")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No fill-ups yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var dataView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Fuel Log", systemImage: "fuelpump.fill")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let costPerKm = entry.costPerKm {
                Text(String(format: "$%.2f/km", costPerKm))
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 2) {
                Text("Last fill-up")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack {
                    Text(String(format: "%.1f L", entry.lastFillLitres))
                        .font(.caption.bold())
                    Spacer()
                    Text(String(format: "$%.2f", entry.lastFillCost))
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
                if let date = entry.lastFillDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(4)
    }
}

struct DriveSocialWidget: Widget {
    let kind: String = "DriveSocialWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FuelWidgetProvider()) { entry in
            DriveSocialWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Fuel Log")
        .description("Shows your last fill-up and running cost per km.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    DriveSocialWidget()
} timeline: {
    FuelWidgetEntry.placeholder
}
