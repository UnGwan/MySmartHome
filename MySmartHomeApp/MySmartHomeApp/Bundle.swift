import Foundation

extension Bundle {
    var apikey: String? {
        return infoDictionary?["API_KEY"] as? String
    }
}
