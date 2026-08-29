import SwiftUI

/// Top-level switcher: shows whichever interface is selected in Settings.
struct RootView: View {
    @StateObject private var settings = AppSettings()

    var body: some View {
        switch settings.mode {
        case .classic:
            ContentView(settings: settings)
        case .training:
            TrainingView(settings: settings)
        }
    }
}

#Preview {
    RootView()
}
