import UIKit
import Social

private let appGroupID = "group.com.oscarcosta.drivesocial"
private let pendingKey = "pendingFuelEntries"

class ShareViewController: SLComposeServiceViewController {
    private var litres: Double = 0
    private var pricePerLitre: Double = 0

    override func isContentValid() -> Bool {
        return litres > 0 && pricePerLitre > 0
    }

    override func didSelectPost() {
        let entry: [String: Any] = [
            "id": UUID().uuidString,
            "date": Date().timeIntervalSince1970,
            "litres": litres,
            "pricePerLitre": pricePerLitre,
            "notes": contentText ?? ""
        ]

        let defaults = UserDefaults(suiteName: appGroupID)
        var pending = (defaults?.array(forKey: pendingKey) as? [[String: Any]]) ?? []
        pending.append(entry)
        defaults?.set(pending, forKey: pendingKey)

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        let litresItem = SLComposeSheetConfigurationItem()!
        litresItem.title = "Litres filled"
        litresItem.value = litres > 0 ? String(format: "%.1f L", litres) : "Tap to enter"
        litresItem.tapHandler = { [weak self] in
            self?.promptValue(title: "Litres filled", key: "litres")
        }

        let priceItem = SLComposeSheetConfigurationItem()!
        priceItem.title = "Price per litre"
        priceItem.value = pricePerLitre > 0 ? String(format: "$%.3f", pricePerLitre) : "Tap to enter"
        priceItem.tapHandler = { [weak self] in
            self?.promptValue(title: "Price per litre (AUD)", key: "price")
        }

        return [litresItem, priceItem]
    }

    private func promptValue(title: String, key: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.keyboardType = .decimalPad
            field.placeholder = "0.00"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self, let text = alert.textFields?.first?.text,
                  let value = Double(text) else { return }
            if key == "litres" { self.litres = value } else { self.pricePerLitre = value }
            self.reloadConfigurationItems()
            self.validateContent()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
