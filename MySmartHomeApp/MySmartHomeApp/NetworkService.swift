import Foundation

class NetworkService {
    // Singleton 인스턴스
    static let shared = NetworkService()
    private init() { }  // 외부에서 인스턴스 생성 방지

    // 서버로 POST 요청을 보내는 함수
    func sendRequest(to url: String, action: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // URL 생성
        guard let requestURL = URL(string: url) else { return }
        
        // URLRequest 설정
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문 설정
        request.httpBody = "action=\(action)".data(using: .utf8)
        
        // 네트워크 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            print("서버 응답: \(String(data: data, encoding: .utf8) ?? "")") // 응답 데이터 로깅
            
            // JSON 파싱
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
