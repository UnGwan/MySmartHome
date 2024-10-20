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
    private let smartModeKey = "smartModeKey"
    private let temperatureKey = "temperatureKey"
    private let humidityKey = "humidityKey"
    
    @Published var statusMessage: String = "인터넷 상태"
    
    @Published var fanSpeed = 1
    @Published var windMode = "Normal"
    @Published var isLedOn = false
    
    //모드 on/off 여부
    @Published var isFanOn = false
    @Published var isSmartMode = false
    
    @Published var isUpDownMode = false
    @Published var isLeftRightMode = false
    
    
    @Published var rotationAngle: Int = 0
    @Published var timerSetting = "Off"
    @Published var temperature : Double = 0.0
    @Published var humidity : Double = 0.0
    
    @Published var smartModeTimer : Timer?
    
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
        // 초기화 메소드
        isUpDownMode = false
        isLeftRightMode = false
        rotationAngle = 0
        fanSpeed = 1
        windMode = "Normal"
        timerSetting = "Off"
    }
    func toggleFanPower() {
        controlMode(action: "P") { success in
            if success {
                self.isFanOn.toggle()
                if self.isFanOn {
                    self.getTempHum()
                } else {
                    self.stopGetTemp()
                }
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
                self.rotationAngle = self.isLeftRightMode ? 30 : 0 // 기본 각도 설정 또는 초기화
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    func adjustAngle() {
        
        controlMode(action: "A") { success in
            if success && self.isLeftRightMode {
                let angles = [30, 60, 90]
                if let currentIndex = angles.firstIndex(of: self.rotationAngle) {
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
        let url = "http://\(apiKey)/api/circulator/"
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
    
    //MARK: 온습도기반 스마트 모드 관련 로직
    
    // 5분마다 온습도를 얻어옴
    func getTempHum() {
        tempMode(action: "")
        smartModeTimer?.invalidate()
        smartModeTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.tempMode(action: "")
        })
    }
    
    //온|습도 모드 실행시 기존 5분마다 실행하던 온습도 모드를 멈추고
    func toggleSmartMode() {
        isSmartMode.toggle()
        if isSmartMode {
            stopGetTemp()
            getTempHum()
        }
    }
    
    // 온|습도 모드 중지 함수
    func stopGetTemp() {
        smartModeTimer?.invalidate() // 타이머 중지
        smartModeTimer = nil
    }
    
    
    //현재 온도에 따라 바람세기 조절해주는 함수
    private func setFanSpeedBasedOnTemperature() {
        
        var goalFanSpeed: Int = 0
        
        // 목표 바람 세기 설정
        switch temperature {
        case ..<18:
            toggleFanPower() // 18도 이하일 때 팬을 끔
        case 18..<20:
            goalFanSpeed = 1
        case 20..<22:
            goalFanSpeed = 2
        case 22..<24:
            goalFanSpeed = 3
        case 24..<26:
            goalFanSpeed = 4
        case 26..<27:
            goalFanSpeed = 5
        case 27..<28:
            goalFanSpeed = 6
        case 28..<29:
            goalFanSpeed = 7
        case 29..<30:
            goalFanSpeed = 8
        case 30..<31:
            goalFanSpeed = 9
        case 31..<32:
            goalFanSpeed = 10
        case 32..<33:
            goalFanSpeed = 11
        case 33..<34:
            goalFanSpeed = 12
        case 34..<35:
            goalFanSpeed = 13
        case 35...:
            goalFanSpeed = 14 // 34도 이상일 때 최대 바람 세기
        default:
            goalFanSpeed = 1
        }
        
        // fanSpeed와 goalFanSpeed의 차이 계산
        let difference = abs(fanSpeed - goalFanSpeed)
        
        for _ in 0..<difference {
            if fanSpeed < goalFanSpeed {
                increaseSpeed()
            } else {
                decreaseSpeed()
            }
            sleep(1)
        }
        saveFanSettings() // 변경된 상태를 저장합니다.
    }
    
    
    //서버에 요청해서 온/습도를 받아온다
    private func tempMode(action: String) {
        let url = "http://\(apiKey)/api/circulator/temperature_humidity"
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let temp = response["temperature"] as? Double , let hum = response["humidity"] as? Double {
                        self.temperature = temp
                        self.humidity = hum
                        if self.isSmartMode {
                            self.setFanSpeedBasedOnTemperature()
                        }
                    }
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                }
            }
        }
        saveFanSettings()
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
        UserDefaults.standard.set(temperature, forKey: temperatureKey)
        UserDefaults.standard.set(humidity, forKey: humidityKey)
        UserDefaults.standard.set(isSmartMode, forKey: smartModeKey)
    }
    
    // UserDefaults에서 팬 설정을 불러오는 메서드
    private func loadFanSettings() {
        isFanOn = UserDefaults.standard.bool(forKey: fanPowerKey)
        fanSpeed = UserDefaults.standard.integer(forKey: fanSpeedKey)
        windMode = UserDefaults.standard.string(forKey: windModeKey) ?? "Normal"
        isLedOn = UserDefaults.standard.bool(forKey: ledStatusKey)
        isUpDownMode = UserDefaults.standard.bool(forKey: upDownModeKey)
        isLeftRightMode = UserDefaults.standard.bool(forKey: leftRightModeKey)
        rotationAngle = UserDefaults.standard.integer(forKey: rotationAngleKey)
        timerSetting = UserDefaults.standard.string(forKey: timerSettingKey) ?? "Off"
        
        isSmartMode = UserDefaults.standard.bool(forKey: smartModeKey)
        temperature = UserDefaults.standard.double(forKey: temperatureKey)
        humidity = UserDefaults.standard.double(forKey: humidityKey)
    }
}
