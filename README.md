# Drive Social

An iOS app for car owners to track trips, log fuel costs, manage service history, find mechanics, and locate cheap fuel nearby.

## Domain Context

Car owners lose track of running costs — fuel spend, service history, and cost per km — because the data is split across paper receipts, notes apps, and memory. Drive Social brings all of it into one place, structured around the lifecycle of owning and driving a vehicle.

## Screens

| Screen | Purpose |
|---|---|
| My Trips | Log and verify driving trips |
| Leaderboard | Friends ranked by verified km |
| My Car | Vehicle profile and service history |
| Find a Mechanic | Search workshops by rating and suburb |
| Fuel Log | Log fill-ups, view cost per km and L/100km |
| Cheap Fuel | Map of nearby stations sorted by price |

## Architecture

```
Views → ViewModels → Use Cases → Repositories → Core Data / In-Memory
```

- **Domain Models** — pure Swift structs named after real-world entities (Trip, FuelEntry, Vehicle, Mechanic)
- **Use Cases** — structs encapsulating one business operation each, with typed domain errors
- **Repositories** — protocol-based, injected into ViewModels; Core Data implementation for fuel data, in-memory for Assessment 2 models
- **ViewModels** — ObservableObject classes, own one repository each, expose @Published state
- **Views** — SwiftUI, read only from ViewModel, never touch repositories or Core Data directly

## System Extensions

### WidgetKit — Fuel Log Widget
Shows last fill-up details and cost per km on the Home Screen. Reads from the App Group shared container. Refreshes every hour and immediately after any fill-up is added.

**User scenario:** Driver wants to know their running cost without opening the app.

### Share Extension
Appears in the system share sheet from Photos, Files, and Safari. User enters litres and price per litre, taps Post — entry is saved to the App Group shared container. Main app imports it on next foreground.

**User scenario:** Driver photographs a fuel receipt and logs the fill-up without switching apps.

## Database

**Core Data** — chosen for offline-first, private, single-device use.

- `VehicleEntity` — one-to-many → `FuelEntryEntity`
- Queries use `NSPredicate` to filter entries by vehicle ID
- All access via `FuelRepositoryProtocol` — ViewModels never call Core Data directly
- `MockFuelRepository` used in all unit tests

## App Group Identifier

`group.com.oscarcosta.drivesocial`

Used by: main app, DriveSocialWidget extension, ShareExtension.

## Use Cases

| Use Case | Business Rule |
|---|---|
| `LogFuelUseCase` | Litres > 0, price > 0, odometer must increase |
| `CalculateCostPerKmUseCase` | Requires ≥ 2 entries; calculates cost/km and L/100km |
| `FindCheapFuelUseCase` | Fetches nearby stations and sorts by price ascending |
| `RecordTripUseCase` | No overlapping trips, distance > 0, end after start |
| `LogMaintenanceUseCase` | Odometer must be ≥ last recorded service odometer |

## Unit Tests

- `LogFuelUseCaseTests` — rejects zero litres, zero price, decreasing odometer; saves valid entry
- `CalculateCostPerKmUseCaseTests` — nil for < 2 entries, correct cost/km, L/100km, total spend
- `RecordTripUseCaseTests` — overlap detection, distance validation
- `LogMaintenanceUseCaseTests` — odometer regression rejection
- `SearchMechanicsUseCaseTests` — recommended/others split by rating threshold

## Git Branching

| Branch | Feature |
|---|---|
| `main` | Stable, submission-ready code |
| `feature/core-data-fuel-log` | Core Data schema, PersistenceController, repositories |
| `feature/fuel-log-ui` | FuelLogViewModel + FuelLogView (5th screen) |
| `feature/widgetkit` | WidgetKit extension, App Group shared defaults |
| `feature/share-extension` | Share Extension for fuel receipts |
| `feature/cheap-fuel` | MapKit + cheap fuel finder (6th screen) |

## Setup

1. Open `Advanced iOS Development - Assessment 2.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities for all targets
3. Ensure the App Group `group.com.oscarcosta.drivesocial` is enabled on: main app, DriveSocialWidget, ShareExtension
4. Press Run on the main app scheme
