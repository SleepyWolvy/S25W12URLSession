import Foundation

struct Weapon: Identifiable, Codable, Hashable {
    let id: Int
    let name: String       // 이름
    let year: Int?         // 년도
    let country: String?   // 제조국
    let caliber: String?   // 구경
    let createdAt: String? // 생성일
    
    // Supabase 컬럼명(snake_case) <-> Swift 변수명(camelCase) 매핑
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case year
        case country
        case caliber
        case createdAt = "created_at"
    }
}
