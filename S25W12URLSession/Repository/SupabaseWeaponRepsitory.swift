import Foundation

public final class SupabaseWeaponRepository: WeaponRepository {
    
    func fetchWeapons() async throws -> [Weapon] {
        let requestURL = URL(string: WeaponApiConfig.serverURL)!
        let (data, _) = try! await URLSession.shared.data(from: requestURL)
        let decoder = JSONDecoder()
        
        return try! decoder.decode([Weapon].self, from: data)
    }
    
    func saveWeapon(_ weapon: Weapon) async throws {
            let requestURL = URL(string: WeaponApiConfig.serverURL)!
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = try JSONEncoder().encode(weapon)
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response
                    as? HTTPURLResponse,
                    httpResponse.statusCode == 201
            else {
                throw URLError(.badServerResponse)
            }
        }
    
    func deleteWeapon(_ id: String) async throws {

        let urlString = "\(WeaponApiConfig.projectURL)/rest/v1/weapons?id=eq.\(id)&apikey=\(WeaponApiConfig.apiKey)"
        let requestURL = URL(string: urlString)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response
                as? HTTPURLResponse,
                httpResponse.statusCode == 204
        else {
            throw URLError(.badServerResponse)
        }
    }
}
