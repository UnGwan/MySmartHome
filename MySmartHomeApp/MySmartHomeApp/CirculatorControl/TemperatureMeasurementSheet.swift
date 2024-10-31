import SwiftUI
import AVFoundation

struct TemperatureMeasurementSheet: View {
    @EnvironmentObject private var viewModel: FanControlViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showCountdown = false 
    @State private var countdownValue = 5
    
    @State private var countdownSoundPlayer: AVAudioPlayer?
    @State private var finishSoundPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack(spacing: 20) {
            if showCountdown {
                VStack {
                    Text("5초간 이마에 센서를 가까이 갖다대주세요")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    Text("\(countdownValue)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.red)
                        .opacity(countdownValue < 6 ? 1.0 : 0.0)
                }
                .frame(width: 300, height: 300)
                .onAppear {
                    setupAudioSession()
                    initializeSoundPlayers()
                }
            } else {
                VStack {
                    Text("적외선 센서를 이마 앞에 갖다대고 버튼을 눌러주세요")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    
                    Image("Example")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .cornerRadius(16)
                }
                
                // 측정 시작 버튼
                Button(action: startCountdown) {
                    Text("5초간 측정")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: countdownValue) { newValue in
            if newValue == 0 {
                playFinishSound()  // 완료 효과음 재생
                dismiss()  // 측정 완료 후 시트 닫기
            }
        }
    }

    // 카운트다운 시작 함수
    private func startCountdown() {
        showCountdown = true
        countdownValue = 6  // 5초로 설정

        // 카운트다운 타이머
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 0 {
                playCountdownSound()  // 효과음 재생
                countdownValue -= 1
                viewModel.startBodyTemperatureMeasurement()
            } else {
                timer.invalidate()
            }
        }
    }

    // 카운트다운 효과음 재생 함수
    private func playCountdownSound() {
        countdownSoundPlayer?.play()
    }

    // 완료 효과음 재생 함수
    private func playFinishSound() {
        finishSoundPlayer?.play()
    }

    // 오디오 세션 설정 함수
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session 설정 오류: \(error)")
        }
    }

    // 효과음 플레이어 초기화 함수
    private func initializeSoundPlayers() {
        if let countdownPath = Bundle.main.url(forResource: "countdownBeep", withExtension: "mp3") {
            countdownSoundPlayer = try? AVAudioPlayer(contentsOf: countdownPath)
            countdownSoundPlayer?.prepareToPlay()
        }
        
        if let finishPath = Bundle.main.url(forResource: "finishSound", withExtension: "mp3") {
            finishSoundPlayer = try? AVAudioPlayer(contentsOf: finishPath)
            finishSoundPlayer?.prepareToPlay()
        }
    }
}
