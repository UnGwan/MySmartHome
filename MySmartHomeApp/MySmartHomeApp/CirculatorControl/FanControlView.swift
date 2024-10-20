import SwiftUI

struct FanControlView: View {
    @EnvironmentObject private var viewModel: FanControlViewModel
    @State private var showResetAlert = false // 리셋 경고 알림 상태
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // 배경색
            LinearGradient(
                gradient: Gradient(colors: viewModel.isFanOn
                                   ? [Color.blue.opacity(0.6), Color.purple.opacity(0.3)]
                                   : [Color.black.opacity(0.8), Color.gray.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack {
                    Text("서큘레이터 리모콘")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.isFanOn ? .primary : .gray)
                        .padding(.bottom, 10)
                    
                    HStack(spacing: 20) {
                        // 감소 버튼
                        Button(action: { viewModel.decreaseSpeed() }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60) // 동일한 크기 설정
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .accessibilityLabel("속도 감소")
                        
                        // 바람 세기 텍스트
                        VStack {
                            Text("Speed")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("\(viewModel.fanSpeed)")
                                .font(.system(size: 40, weight: .bold)) // 스피드 텍스트 크기 증가
                                .foregroundColor(.blue)
                        }
                        .frame(width: 120) // 텍스트 영역 고정
                        
                        // 증가 버튼
                        Button(action: { viewModel.increaseSpeed() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60) // 동일한 크기 설정
                                .background(Color.purple)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .accessibilityLabel("속도 증가")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .opacity(viewModel.isFanOn ? 1.0 : 0.0)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isFanOn)
                    
                    // 상태 정보 그리드
                    LazyVGrid(columns: columns, spacing: 20) {
                        InfoCard(title: "모드", value: viewModel.windMode, color: .blue)
                        InfoCard(title: "각도", value: "\(viewModel.rotationAngle)°", color: .purple)
                        InfoCard(title: "타이머", value: viewModel.timerSetting, color: .orange)
                        InfoCard(title: "방 온도", value: String(format: "%.1f°C", viewModel.temperature), color: .red)
                        InfoCard(title: "방 습도", value: String(format: "%.1f%%", viewModel.humidity), color: .green)
                        InfoCard(title: "내 체온", value: String(format: "%.1f°C", viewModel.temperature), color: .pink)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6)))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .opacity(viewModel.isFanOn ? 1.0 : 0.0)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isFanOn)
                }
                
                VStack(spacing: 15) {
                    // 전원 버튼
                    Button(action: { viewModel.toggleFanPower() }) {
                        HStack {
                            Image(systemName: "power")
                            Text(viewModel.isFanOn ? "Power Off" : "Power On")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(viewModel.isFanOn ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .accessibilityLabel(viewModel.isFanOn ? "전원 끄기" : "전원 켜기")
                    
                    if viewModel.isFanOn {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ModeButton(title: "온/습도 모드", isActive: viewModel.isSmartMode, action: { viewModel.toggleSmartMode() }, color: .blue)
                                
                                ModeButton(title: "체온 모드", isActive: false, action: { }, color: .purple)
                            }
                            
                            HStack(spacing: 10) {
                                FunctionButton(title: "Wind Mode", systemImage: "wind", color: .blue.opacity(0.2), action: { viewModel.cycleWindMode() }, isActive: true)
                                
                                FunctionButton(title: "Timer", systemImage: "timer", color: .yellow.opacity(0.2), action: { viewModel.cycleTimer() }, isActive: true)
                            }
                            
                            HStack(spacing: 10) {
                                FunctionButton(title: "상/하", systemImage: "arrow.up.arrow.down.circle.fill", color: .blue.opacity(0.2), action: { viewModel.toggleUpDownRotation() }, isActive: viewModel.isUpDownMode)
                                
                                FunctionButton(title: "좌/우", systemImage: "arrow.left.arrow.right.circle.fill", color: .red.opacity(0.2), action: { viewModel.toggleLeftRightRotation() }, isActive: viewModel.isLeftRightMode)
                                
                                FunctionButton(title: "각도", systemImage: "rotate.3d", color: Color.purple.opacity(0.2), action: { viewModel.adjustAngle() }, isActive: viewModel.isLeftRightMode)
                            }
                        }
                    }
                    
                    if !viewModel.isFanOn {
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Reset Data")
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
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
            }
            .padding()
        }
        .onAppear {
            if viewModel.smartModeTimer == nil {
                viewModel.getTempHum()
            }
        }
    }
    
    // 정보 카드 뷰
    struct InfoCard: View {
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            .frame(width: 100, height: 80)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6)))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // 모드 버튼 뷰
    struct ModeButton: View {
        let title: String
        let isActive: Bool
        let action: () -> Void
        let color: Color
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: isActive ? "checkmark.circle" : "minus.circle")
                    Text(title)
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isActive ? color : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel(title)
        }
    }
    
    // 기능 버튼 뷰
    struct FunctionButton: View {
        let title: String
        let systemImage: String
        let color: Color
        let action: () -> Void
        let isActive: Bool
        
        var body: some View {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(isActive ? color : Color.gray)
                    .foregroundColor(isActive ? Color.white : Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            .accessibilityLabel(title)
        }
    }
}
