import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject private var viewModel : LEDControlViewModel
    var body: some View {
            ZStack {
                // 부드러운 그라데이션 배경
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.4), Color.blue.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // 메인 타이틀 - 스마트 홈
                    Text("스마트 홈")
                        .bold()
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)

                    // LED Control 버튼
                    NavigationLink(destination: LEDControlView()) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("LED Control")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3)) // 버튼 배경 강화
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    
                    NavigationLink(destination: FanControlView()) {
                        HStack {
                            Image(systemName: "wind")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("Fan Control")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3)) // 버튼 배경 강화
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }

                    // 향후 추가될 버튼 예시
                    Button(action: {
                        // 다른 기능 추가 예정
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Settings")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3)) // 버튼 배경 강화
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchedLEDStatus()
            }
        }
}

#Preview {
    MainHomeView()
}
