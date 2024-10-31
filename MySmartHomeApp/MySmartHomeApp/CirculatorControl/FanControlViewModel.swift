import SwiftUI
import AVFoundation

class FanControlViewModel: ObservableObject {
    // MARK: - UserDefaults 키 정의
    private enum Keys {
        static let fanPower = "fanPowerKey"
        static let fanSpeed = "fanSpeedKey"
        static let windMode = "windModeKey"
        static let ledStatus = "ledStatusKey"
        static let upDownMode = "upDownModeKey"
        static let leftRightMode = "leftRightModeKey"
        static let rotationAngle = "rotationAngleKey"
        static let timerSetting = "timerSettingKey"
        static let smartMode = "smartModeKey"
        static let temperature = "temperatureKey"
        static let humidity = "humidityKey"
        static let myTemperature = "MyTemperatureKey"
        static let fanSpeedSettings = "fanSpeedSettings"
        static let temperatureInterval = "temperatureIntervalKey"
        static let detectionInterval = "detectionIntervalKey"
        static let inactivityDuration = "inactivityDurationKey"
    }
    
    // MARK: - 상태 관리 변수
    @Published var statusMessage: String = "인터넷 상태"
    @Published var fanSpeed = 1
    @Published var windMode = "Normal"
    @Published var isLedOn = false
    @Published var isFanOn = false
    @Published var isSmartMode = false
    @Published var isAutoControlMode = false
    @Published var isUpDownMode = false
    @Published var isLeftRightMode = false
    @Published var rotationAngle: Int = 0
    @Published var timerSetting = "Off"
    @Published var myTemperature: Double = 0.0
    @Published var temperature: Double = 0.0
    @Published var humidity: Double = 0.0
    @Published var inactivityDuration: Int = 5 {
        didSet {
            saveFanSettings()
            stopPersonDetection()
        }
    }
    @Published var smartModeTimer: Timer?
    @Published var temperatureInterval: Int = 5
    @Published var detectionInterval: Int = 5
    @Published var fanSpeedSettings: [Int: FanSpeedSetting] = [
        1: FanSpeedSetting(lowerBound: 18.0, upperBound: 20.0),
        2: FanSpeedSetting(lowerBound: 20.0, upperBound: 22.0),
        3: FanSpeedSetting(lowerBound: 22.0, upperBound: 24.0),
        4: FanSpeedSetting(lowerBound: 24.0, upperBound: 26.0),
        5: FanSpeedSetting(lowerBound: 26.0, upperBound: 27.0),
        6: FanSpeedSetting(lowerBound: 27.0, upperBound: 28.0),
        7: FanSpeedSetting(lowerBound: 28.0, upperBound: 29.0),
        8: FanSpeedSetting(lowerBound: 29.0, upperBound: 30.0),
        9: FanSpeedSetting(lowerBound: 30.0, upperBound: 31.0),
        10: FanSpeedSetting(lowerBound: 31.0, upperBound: 32.0),
        11: FanSpeedSetting(lowerBound: 32.0, upperBound: 33.0),
        12: FanSpeedSetting(lowerBound: 33.0, upperBound: 34.0),
        13: FanSpeedSetting(lowerBound: 34.0, upperBound: 35.0),
        14: FanSpeedSetting(lowerBound: 35.0, upperBound: 36.0)
    ] {
        didSet { saveFanSettings() }
    }
    
    // MARK: - 개인 정보
    private var temperatureRecord: [Double] = []
    private var personDetectionCount = 0
    private var temperatureTimer: Timer?
    
    // MARK: - API 키
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return key
    }
    
    // MARK: - 초기화
    init() { loadFanSettings() }
    
    // MARK: - 전체 설정 초기화
    func allReset() {
        isUpDownMode = false
        isLeftRightMode = false
        rotationAngle = 0
        fanSpeed = 1
        windMode = "Normal"
        timerSetting = "Off"
    }
    
    // MARK: - 전원 토글
    func toggleFanPower() {
        controlMode(action: "P") { success in
            if success {
                self.isFanOn.toggle()
                self.isFanOn ? self.getTempHum() : self.stopGetTemp()
                self.saveFanSettings()
            } else {
                self.statusMessage = "팬 전원 조절에 실패했습니다."
            }
        }
        if !isFanOn {
            stopPersonDetection()
            stopGetTemp()
        }
    }
    
    // MARK: - 팬 속도 조절
    func increaseSpeed() {
        controlMode(action: "U") { success in
            if success && self.isFanOn {
                self.fanSpeed = min(self.fanSpeed + 1, 14)
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 상승 실패"
            }
        }
    }
    
    func decreaseSpeed() {
        controlMode(action: "D") { success in
            if success && self.isFanOn {
                self.fanSpeed = max(self.fanSpeed - 1, 1)
                self.saveFanSettings()
            } else {
                self.statusMessage = "바람세기 하락 실패"
            }
        }
    }
    
    // MARK: - 모드 제어
    func cycleWindMode() {
        controlMode(action: "M") { success in
            guard success && self.isFanOn else { self.statusMessage = "바람 모드 전환 실패"; return }
            let modes = ["Normal", "Baby", "Turbo", "AI"]
            if let currentIndex = modes.firstIndex(of: self.windMode) {
                self.windMode = modes[(currentIndex + 1) % modes.count]
                self.saveFanSettings()
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
                self.statusMessage = "타이머 설정 실패"
            }
        }
    }
    
    // MARK: - 상하좌우 조절
    func toggleUpDownRotation() {
        controlMode(action: "S") { success in
            if success && self.isFanOn {
                self.isUpDownMode.toggle()
                self.saveFanSettings()
            } else {
                self.statusMessage = "상하 모드 전환 실패"
            }
        }
    }
    
    func toggleLeftRightRotation() {
        controlMode(action: "G") { success in
            if success && self.isFanOn {
                self.isLeftRightMode.toggle()
                self.rotationAngle = self.isLeftRightMode ? 30 : 0
                self.saveFanSettings()
            } else {
                self.statusMessage = "좌우 모드 전환 실패"
            }
        }
    }
    
    func adjustAngle() {
        controlMode(action: "A") { success in
            guard success && self.isLeftRightMode else { self.statusMessage = "각도 조절 실패"; return }
            let angles = [30, 60, 90]
            if let currentIndex = angles.firstIndex(of: self.rotationAngle) {
                self.rotationAngle = angles[(currentIndex + 1) % angles.count]
                self.saveFanSettings()
            }
        }
    }
    
    // MARK: - 스마트 모드와 타이머 설정
    func getTempHum() {
        fetchTemperatureData(action: "", viewName: "temperature_humidity")
        
        var intervalInSeconds = Double(temperatureInterval) * 60
        if intervalInSeconds == 0.0 {
            intervalInSeconds = 60
        }
        print("주기:\(intervalInSeconds)")
        smartModeTimer?.invalidate()
        smartModeTimer = Timer.scheduledTimer(withTimeInterval: intervalInSeconds, repeats: true) { [weak self] _ in
            self?.fetchTemperatureData(action: "", viewName: "temperature_humidity")
        }
    }
    
    func toggleSmartMode() {
        isSmartMode.toggle()
        isSmartMode ? getTempHum() : stopGetTemp()
        saveFanSettings()
    }
    
    func stopGetTemp() {
        smartModeTimer?.invalidate()
        smartModeTimer = nil
    }
    
    func setFanSpeedBasedOnTemperature() {
        var goalFanSpeed: Int = 0
        
        for (speed, setting) in fanSpeedSettings {
            if setting.lowerBound <= temperature && temperature < setting.upperBound {
                goalFanSpeed = speed
                break
            }
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
        
        saveFanSettings()
    }
    
    // MARK: - 사람 감지 및 체온 측정
    func startBodyTemperatureMeasurement() {
        fetchTemperatureData(action: "GET", viewName: "myTemperature") { temperature in
            self.temperatureRecord.append(temperature)
            if self.temperatureRecord.count == 5 {
                self.myTemperature = self.temperatureRecord.max() ?? 0.0
                self.saveFanSettings()
                self.temperatureRecord.removeAll()
            }
        }
    }
    
    func startPersonDetection() {
        isAutoControlMode = true
        personDetectionCount = 0
        startTemperatureTimer()
    }
    
    func stopPersonDetection() {
        isAutoControlMode = false
        temperatureTimer?.invalidate()
    }
    
    private func startTemperatureTimer() {
        if inactivityDuration == 0 {
            inactivityDuration = 5
        }
        temperatureTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.fetchTemperatureData(action: "GET", viewName: "myTemperature") { temperature in
                self.personDetectionCount = temperature < 26.0 ? self.personDetectionCount + 1 : 0
                if self.personDetectionCount >= self.inactivityDuration {
                    self.stopPersonDetection()
                    self.toggleFanPower()
                }
            }
        }
    }
    
    // MARK: - 네트워크 요청
    private func controlMode(action: String, completion: @escaping (Bool) -> Void) {
        let url = "http://\(apiKey)/api/circulator/"
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.statusMessage = response["message"] as? String ?? "알 수 없는 응답"
                    completion(true)
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    private func fetchTemperatureData(action: String, viewName: String) {
        let url = "http://\(apiKey)/api/circulator/\(viewName)"
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if viewName == "temperature_humidity" {
                        if let temp = response["temperature"] as? Double , let hum = response["humidity"] as? Double {
                            self.temperature = temp
                            self.humidity = hum
                            if self.isSmartMode {
                                self.setFanSpeedBasedOnTemperature()
                            }
                        }
                    }
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                }
            }
        }
        saveFanSettings()
    }
    
    private func fetchTemperatureData(action: String, viewName: String, completion: ((Double) -> Void)? = nil) {
        let url = "http://\(apiKey)/api/circulator/\(viewName)"
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let temp = response["my_temperature"] as? Double {
                        completion?(temp)
                    }
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - UserDefaults에 상태 저장
    private func saveFanSettings() {
        UserDefaults.standard.set(isFanOn, forKey: Keys.fanPower)
        UserDefaults.standard.set(fanSpeed, forKey: Keys.fanSpeed)
        UserDefaults.standard.set(windMode, forKey: Keys.windMode)
        UserDefaults.standard.set(isLedOn, forKey: Keys.ledStatus)
        UserDefaults.standard.set(isUpDownMode, forKey: Keys.upDownMode)
        UserDefaults.standard.set(isLeftRightMode, forKey: Keys.leftRightMode)
        UserDefaults.standard.set(rotationAngle, forKey: Keys.rotationAngle)
        UserDefaults.standard.set(timerSetting, forKey: Keys.timerSetting)
        UserDefaults.standard.set(isSmartMode, forKey: Keys.smartMode)
        UserDefaults.standard.set(myTemperature, forKey: Keys.myTemperature)
        UserDefaults.standard.set(temperatureInterval, forKey: Keys.temperatureInterval)
        UserDefaults.standard.set(inactivityDuration, forKey: Keys.inactivityDuration)
        
        if let data = try? JSONEncoder().encode(fanSpeedSettings) {
            UserDefaults.standard.set(data, forKey: Keys.fanSpeedSettings)
        }
    }
    
    private func loadFanSettings() {
        isFanOn = UserDefaults.standard.bool(forKey: Keys.fanPower)
        fanSpeed = UserDefaults.standard.integer(forKey: Keys.fanSpeed)
        windMode = UserDefaults.standard.string(forKey: Keys.windMode) ?? "Normal"
        isLedOn = UserDefaults.standard.bool(forKey: Keys.ledStatus)
        isUpDownMode = UserDefaults.standard.bool(forKey: Keys.upDownMode)
        isLeftRightMode = UserDefaults.standard.bool(forKey: Keys.leftRightMode)
        rotationAngle = UserDefaults.standard.integer(forKey: Keys.rotationAngle)
        timerSetting = UserDefaults.standard.string(forKey: Keys.timerSetting) ?? "Off"
        isSmartMode = UserDefaults.standard.bool(forKey: Keys.smartMode)
        temperatureInterval = UserDefaults.standard.integer(forKey: Keys.temperatureInterval)
        inactivityDuration = UserDefaults.standard.integer(forKey: Keys.inactivityDuration)
        myTemperature = UserDefaults.standard.double(forKey: Keys.myTemperature)
        
           if let savedData = UserDefaults.standard.data(forKey: Keys.fanSpeedSettings),
              let decodedData = try? JSONDecoder().decode([Int: FanSpeedSetting].self, from: savedData) {
               fanSpeedSettings = decodedData
           } else {
               // 기본 fanSpeedSettings 값을 설정
               fanSpeedSettings = [
                   1: FanSpeedSetting(lowerBound: 18.0, upperBound: 20.0),
                   2: FanSpeedSetting(lowerBound: 20.0, upperBound: 22.0),
                   3: FanSpeedSetting(lowerBound: 22.0, upperBound: 24.0),
                   4: FanSpeedSetting(lowerBound: 24.0, upperBound: 26.0),
                   5: FanSpeedSetting(lowerBound: 26.0, upperBound: 27.0),
                   6: FanSpeedSetting(lowerBound: 27.0, upperBound: 28.0),
                   7: FanSpeedSetting(lowerBound: 28.0, upperBound: 29.0),
                   8: FanSpeedSetting(lowerBound: 29.0, upperBound: 30.0),
                   9: FanSpeedSetting(lowerBound: 30.0, upperBound: 31.0),
                   10: FanSpeedSetting(lowerBound: 31.0, upperBound: 32.0),
                   11: FanSpeedSetting(lowerBound: 32.0, upperBound: 33.0),
                   12: FanSpeedSetting(lowerBound: 33.0, upperBound: 34.0),
                   13: FanSpeedSetting(lowerBound: 34.0, upperBound: 35.0),
                   14: FanSpeedSetting(lowerBound: 35.0, upperBound: 36.0)
               ]
           }
    }
}

// MARK: - 바람 세기 설정 구조체
struct FanSpeedSetting: Codable {
    var lowerBound: Double
    var upperBound: Double
}
