import SwiftUI

struct FanControlView: View {
    @EnvironmentObject private var viewModel: FanControlViewModel
    @State private var showResetAlert = false // 리셋 경고 알림 상태
    
    var body: some View {
        ZStack {
            // 전원 상태에 따라 배경색 변경
            LinearGradient(
                gradient: Gradient(colors: viewModel.isFanOn
                                   ? [Color.white.opacity(0.95), Color(UIColor.systemGray6)] // 밝은 흰색 계열
                                   : [Color.black.opacity(0.85), Color(UIColor.systemGray4)] // 어두운 검은색 계열
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 상단 섹션: 팬 상태
                VStack {
                    Text("서큘레이터 리모콘")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.isFanOn ? .black : .gray)
                        .padding(.bottom, 10)
                    
                    // 팬 속도 중앙 강조, 모드/각도/타이머를 좌우에 배치
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text("Mode")
                                .foregroundColor(.black)
                            Text(viewModel.windMode)
                                .foregroundColor(viewModel.isFanOn ? .green : .gray)
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30) // 아이콘 확대
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                                .opacity(viewModel.isUpDownMode ? 1 : 0.0)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("speed")
                                .fontWeight(.light)
                                .opacity(viewModel.isFanOn ? 1.0 : 0.0)
                            Text("\(viewModel.fanSpeed)")
                                .font(.system(size: 100))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .opacity(viewModel.isFanOn ? 1.0 : 0.0)
                            if viewModel.isLeftRightMode, let angle = viewModel.rotationAngle {
                                Text("Angle: \(angle)")
                            }
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Timer")
                                .foregroundColor(.black)
                            Text(viewModel.timerSetting)
                                .foregroundColor(viewModel.isFanOn ? .orange : .gray)
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30) // 아이콘 확대
                                .foregroundColor(.red)
                                .padding(.top, 5)
                                .opacity(viewModel.isLeftRightMode ? 1 : 0.0)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                
                Spacer() // 상태 영역과 버튼 영역 사이 간격 유지
                
                VStack(spacing: 15) {
                    // 전원 버튼
                    Button(action: { viewModel.toggleFanPower() }) {
                        Label(viewModel.isFanOn ? "Power Off" : "Power On", systemImage: "power")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFanOn ? Color.green : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    if viewModel.isFanOn {
                        // 바람 세기 조절
                        HStack {
                            Button(action: { viewModel.decreaseSpeed() }) {
                                Label("-", systemImage: "minus.circle")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                            }
                            Text("Speed")
                                .foregroundColor(.white)
                            Button(action: { viewModel.increaseSpeed() }) {
                                Label("+", systemImage: "plus.circle")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // 바람 모드 버튼
                        Button(action: { viewModel.cycleWindMode() }) {
                            Label("Wind Mode", systemImage: "wind")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                        
                        HStack {
                            Button(action: { viewModel.toggleUpDownRotation() }) {
                                Label("Up/Down", systemImage: "arrow.up.arrow.down.circle.fill")
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                            Button(action: { viewModel.toggleLeftRightRotation() }) {
                                Label("Left/Right", systemImage: "arrow.left.arrow.right.circle.fill")
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                            }
                            if viewModel.isLeftRightMode {
                                Button(action: { viewModel.adjustAngle() }) {
                                    Label("Adjust Angle", systemImage: "rotate.3d")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        Button(action: { viewModel.cycleTimer() }) {
                            Label("Timer", systemImage: "timer")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow.opacity(0.2))
                                .foregroundColor(.yellow)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { viewModel.toggleFanLED() }) {
                            Label("LED", systemImage: viewModel.isLedOn ? "lightbulb.fill" : "lightbulb")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                    
                    // 데이터 리셋 버튼
                    if !viewModel.isFanOn {
                        Button(action: { showResetAlert = true }) {
                            Label("Reset Data", systemImage: "exclamationmark.triangle.fill")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .alert(isPresented: $showResetAlert) {
                            Alert(
                                title: Text("Reset All Data"),
                                message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                                primaryButton: .destructive(Text("Reset")) {
                                    viewModel.allReset()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                Spacer() // 상태 표시와 버튼 섹션 분리
            }
        }
    }
}
