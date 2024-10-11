import SwiftUI

class FanControlViewModel: ObservableObject {
    // 팬 설정 상태를 저장할 UserDefaults 키 정의
    private let fanPowerKey = "fanPowerKey"
    private let fanSpeedKey = "fanSpeedKey"
    private let windModeKey = "windModeKey"
    private let ledStatusKey = "ledStatusKey"
    private let upDownModeKey = "upDownModeKey"
    private let leftRightModeKey = "leftRightModeKey"
    private let rotationAngleKey = "rotationAngleKey"
    private let timerSettingKey = "timerSettingKey"
    
    @Published var statusMessage: String = "인터넷 상태"
    @Published var isFanOn = false
    @Published var fanSpeed = 1
    @Published var windMode = "Normal"
    @Published var isLedOn = false
    @Published var isUpDownMode = false
    @Published var isLeftRightMode = false
    @Published var rotationAngle: Int? = nil
    @Published var timerSetting = "Off"
    
    private var apiKey: String {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
                fatalError("API_KEY not found in Info.plist")
            }
        return apiKey
    }
    
    init() {
        loadFanSettings() // 초기화 시 저장된 상태 불러오기
    }
    func allReset() {
            // 전원이 꺼질 때 상태 초기화
        isUpDownMode = false
        isLeftRightMode = false
        rotationAngle = nil
        fanSpeed = 1
        windMode = "Normal"
        timerSetting = "Off"
    }
    func toggleFanPower() {
        controlMode(action: "P") { success in
            if success {
                self.isFanOn.toggle()
                self.saveFanSettings()
            } else {
                self.statusMessage = "팬 전원 조절에 실패했습니다."
            }
        }
    }
    
    func increaseSpeed() {
        controlMode(action: "U") { success in
            if success && self.isFanOn {
                self.fanSpeed = self.fanSpeed < 14 ? self.fanSpeed + 1 : 1
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 상승 실패"
            }
        }

    }
    
    func decreaseSpeed() {
        controlMode(action: "D") { success in
            if success && self.isFanOn {
                self.fanSpeed = self.fanSpeed > 1 ? self.fanSpeed - 1 : 14
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func cycleWindMode() {
        controlMode(action: "M") { success in
            if success && self.isFanOn {
                let modes = ["Normal", "Baby", "Turbo", "AI"]
                if let currentIndex = modes.firstIndex(of: self.windMode) {
                    self.windMode = modes[(currentIndex + 1) % modes.count]
                    self.saveFanSettings()
                }
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func toggleUpDownRotation() {
        
        controlMode(action: "S") { success in
            if success && self.isFanOn {
                self.isUpDownMode.toggle()
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }

    }
    
    func toggleLeftRightRotation() {
        controlMode(action: "G") { success in
            if success && self.isFanOn {
                self.isLeftRightMode.toggle()
                self.rotationAngle = self.isLeftRightMode ? 30 : nil  // 기본 각도 설정 또는 초기화
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func adjustAngle() {
        
        controlMode(action: "A") { success in
            if success && self.isLeftRightMode, let angle = self.rotationAngle {
                let angles = [30, 60, 90]
                if let currentIndex = angles.firstIndex(of: angle) {
                    self.rotationAngle = angles[(currentIndex + 1) % angles.count]
                    self.saveFanSettings()
                }
               
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func cycleTimer() {
        
        controlMode(action: "T") { success in
            if success && self.isFanOn {
                let timers = ["Off", "30 mins", "1 hour", "2 hours", "4 hours", "8 hours"]
                if let currentIndex = timers.firstIndex(of: self.timerSetting) {
                    self.timerSetting = timers[(currentIndex + 1) % timers.count]
                    self.saveFanSettings()
                }
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func toggleFanLED() {
        if isFanOn {
            isLedOn.toggle()
            saveFanSettings()
        }
    }
    
    private func controlMode(action: String, completion: @escaping (Bool) -> Void) {
        let url = "http://\(apiKey)/api/circulator/"  // 실제 URL로 변경
        
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response["message"] as? String {
                        self.statusMessage = message
                        completion(true)  // 성공 시 true를 전달
                    } else {
                        self.statusMessage = "알 수 없는 응답"
                        completion(false)
                    }
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                    completion(false)  // 실패 시 false를 전달
                }
            }
        }
    }
    
    // UserDefaults에 현재 팬 상태를 저장하는 메서드
    private func saveFanSettings() {
        UserDefaults.standard.set(isFanOn, forKey: fanPowerKey)
        UserDefaults.standard.set(fanSpeed, forKey: fanSpeedKey)
        UserDefaults.standard.set(windMode, forKey: windModeKey)
        UserDefaults.standard.set(isLedOn, forKey: ledStatusKey)
        UserDefaults.standard.set(isUpDownMode, forKey: upDownModeKey)
        UserDefaults.standard.set(isLeftRightMode, forKey: leftRightModeKey)
        UserDefaults.standard.set(rotationAngle, forKey: rotationAngleKey)
        UserDefaults.standard.set(timerSetting, forKey: timerSettingKey)
    }
    
    // UserDefaults에서 팬 설정을 불러오는 메서드
    private func loadFanSettings() {
        isFanOn = UserDefaults.standard.bool(forKey: fanPowerKey)
        fanSpeed = UserDefaults.standard.integer(forKey: fanSpeedKey)
        windMode = UserDefaults.standard.string(forKey: windModeKey) ?? "Normal"
        isLedOn = UserDefaults.standard.bool(forKey: ledStatusKey)
        isUpDownMode = UserDefaults.standard.bool(forKey: upDownModeKey)
        isLeftRightMode = UserDefaults.standard.bool(forKey: leftRightModeKey)
        rotationAngle = UserDefaults.standard.object(forKey: rotationAngleKey) as? Int
        timerSetting = UserDefaults.standard.string(forKey: timerSettingKey) ?? "Off"
    }
}
