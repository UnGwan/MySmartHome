import SwiftUI

struct SettingsView: View {
    var body: some View {
            NavigationView {
                Form {
                    Section {
                        NavigationLink(destination: TemperatureModeSettingsView()) {
                            Text("온도 모드 설정")
                        }
                        NavigationLink(destination: PersonDetectionModeSettingsView()) {
                            Text("사람 감지 모드 설정")
                        }
                    }
                }
                .navigationBarTitle("설정", displayMode: .inline)
            }
    }
}
