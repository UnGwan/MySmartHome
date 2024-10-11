import Foundation

class NetworkService {
    // 싱글톤 인스턴스 선언
    static let shared = NetworkService()
    
    // private 생성자를 통해 외부에서 인스턴스 생성을 방지
    private init() { }
    
    // 서버로 POST 요청을 보내는 함수
    func sendRequest(to url: String, action: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // URL 생성 및 유효성 검사
        guard let requestURL = URL(string: url) else { return }
        
        // URLRequest 생성 및 설정
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"  // HTTP 메소드 설정
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")  // 요청 헤더 설정
        
        // 요청 본문 설정
        let body = "action=\(action)"
        request.httpBody = body.data(using: .utf8)
        
        // URLSession을 사용한 네트워크 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러 발생 시 에러 반환
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 데이터 유효성 검사
            guard let data = data else { return }
            
            // 응답 데이터 로깅
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답: \(responseString)")
            }
            
            // JSON 파싱 시도
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(responseJSON))
                } else {
                    // JSON 형식이 아닐 때 에러 처리
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "잘못된 JSON 형식"])))
                }
            } catch {
                // 파싱 에러 처리
                completion(.failure(error))
            }
        }.resume()  // 네트워크 요청 시작
    }
}
