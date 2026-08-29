import Foundation
import Combine

enum AppMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case training = "Training"
    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .classic:
            return "Tap to decode into text, one letter at a time."
        case .training:
            return "See the full chart light up live as you tap, so you learn which letters your pattern can still become."
        }
    }
}

/// Shared, persisted app-wide settings.
final class AppSettings: ObservableObject {
    @Published var mode: AppMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "appMode") }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appMode") ?? AppMode.classic.rawValue
        self.mode = AppMode(rawValue: saved) ?? .classic
    }
}
