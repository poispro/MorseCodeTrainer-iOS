import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Interface Mode", selection: $settings.mode) {
                        ForEach(AppMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)

                    Text(settings.mode.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Mode")
                } footer: {
                    Text("Switch anytime — your progress and any recording are kept per session.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
