import SwiftUI

struct LEDControlView: View {
    // LED 상태 변수
    @State private var isLedOn = false
    @EnvironmentObject private var viewModel : LEDControlViewModel

    var body: some View {
        ZStack {
            // 전체 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // 전체 화면에 그라데이션 적용

            VStack(spacing: 20) {
                // LED 상태에 따른 전구 이미지
                Image(systemName: viewModel.ledStatus ? "lightbulb.fill" : "lightbulb.slash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150) // 전구 이미지 크기 조절
                    .foregroundColor(viewModel.ledStatus ? .yellow : .gray)
                    .padding(.bottom, 20)

                // 현재 LED 상태를 표시하는 텍스트
                Text(viewModel.ledStatus ? "LED가 켜져 있습니다" : "LED가 꺼져 있습니다")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.ledStatus ? .green : .red)
                    .padding()

                // LED 끄기 버튼
                Button(action: {
                    withAnimation {
                        viewModel.controlLED(action: "off")
                        viewModel.ledStatus = false
                    }
                }) {
                    HStack {
                        Image(systemName: "lightbulb.slash.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text("LED 끄기")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .disabled(!viewModel.ledStatus) // LED가 이미 꺼져 있으면 버튼 비활성화

                // LED 켜기 버튼
                Button(action: {
                    withAnimation {
                        viewModel.ledStatus = true
                        viewModel.controlLED(action: "on")
                    }
                }) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        Text("LED 켜기")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .disabled(viewModel.ledStatus) // LED가 이미 켜져 있으면 버튼 비활성화
                Text(viewModel.statusMessage)
                                .padding()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // VStack이 전체 화면을 채우도록 설정
        }
    }
}

#Preview {
    LEDControlView()
}
