import Foundation
class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {
    }

    func sendRequest(to url: String, action: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let requestURL = URL(string: url) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "action=\(action)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            // 응답 데이터 확인을 위해 디버깅용 출력 추가
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답: \(responseString)")
            }
            
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(responseJSON))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "잘못된 JSON 형식"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
