import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject private var viewModel : LEDControlViewModel
    var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.4), Color.blue.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("스마트 홈")
                        .bold()
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)

                    NavigationLink(destination: LEDControlView()) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("LED 제어")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    
                    NavigationLink(destination: FanControlView()) {
                        HStack {
                            Image(systemName: "wind")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("서큘레이터 제어")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("설정")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding()
            }
        }
}

