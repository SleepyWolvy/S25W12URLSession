import SwiftUI

@MainActor
@Observable
final class WeaponViewModel {
    private let repository: WeaponRepository
        
    init(repository: WeaponRepository = SupabaseWeaponRepository()) {
        self.repository = repository
    }

    
    private var _weapons: [Weapon] = []
    
    
    var weapons: [Weapon] { _weapons }

    var path = NavigationPath()

    func loadWeapons() async {
        
        if let fetched = try? await repository.fetchWeapons() {
             _weapons = fetched
        }
    }
    
    func addWeapon(_ weapon: Weapon) async {
        do {
            try await repository.saveWeapon(weapon)
            _weapons.append(weapon)
        }
        catch {
            debugPrint("에러 발생: \(error)")
        }
    }
    
    func deleteWeapon(_ weapon: Weapon) async {
        do {
            try await repository.deleteWeapon(String(weapon.id))
            if let index = _weapons.firstIndex(where: { $0.id == weapon.id }) {
                _weapons.remove(at: index)
            }
        }
        catch {
            debugPrint("에러 발생: \(error)")
        }
    }
}
