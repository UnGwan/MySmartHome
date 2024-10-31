import SwiftUI

struct PersonDetectionModeSettingsView: View {
    @EnvironmentObject var viewModel: FanControlViewModel
    @State private var inactivityDuration: Double = 5  

    var body: some View {
        VStack(spacing: 20) {
            Text("사람 감지 모드 설정")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top)

            Text("사람이 감지되지 않으면 전원이 자동으로 꺼집니다.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // 시간 설정 슬라이더
            VStack {
                Text("전원 종료까지 대기 시간 (분): \(Int(inactivityDuration))분")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Slider(value: $inactivityDuration, in: 1...30, step: 1)
                    .accentColor(.blue)
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
            
            // 저장 버튼
            Button(action: saveSettings) {
                Text("설정 저장")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(15)
        .padding()
        .navigationBarTitle("사람 감지 모드 설정", displayMode: .inline)
        .onAppear {
            inactivityDuration = Double(viewModel.inactivityDuration)
        }
    }
    
    // 설정 저장 함수
    private func saveSettings() {
        viewModel.inactivityDuration = Int(inactivityDuration)
    }
}
