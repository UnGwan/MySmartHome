// LEDControlViewModel.swift

import Foundation
import Combine

class LEDControlViewModel: ObservableObject {
    @Published var statusMessage: String = "인터넷 상태"
    @Published var ledStatus: Bool = false
    private var apiKey: String {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
                fatalError("API_KEY not found in Info.plist")
            }
        return apiKey
    }
    
    func controlLED(action: String) {
        let url = "http://\(apiKey)/api/led/"  // 실제 URL로 변경
        
        NetworkService.shared.sendRequest(to: url, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response["message"] as? String {
                        self.statusMessage = message
                    } else {
                        self.statusMessage = "알 수 없는 응답"
                    }
                case .failure(let error):
                    self.statusMessage = "오류: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchedLEDStatus() {
        guard let url = URL(string: "http://\(apiKey)/api/led/status") else { return }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error fetching LED status: \(error)")
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let status = jsonResponse["status"] as? String {
                            DispatchQueue.main.async {
                                if status == "on" {
                                    self.ledStatus = true
                                } else {
                                    self.ledStatus = false
                                }
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }.resume()
    }
}
