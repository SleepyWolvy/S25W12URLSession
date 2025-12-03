protocol WeaponRepository: Sendable {

    func fetchWeapons() async throws -> [Weapon]
    
    func saveWeapon(_ weapon: Weapon) async throws
    
    func deleteWeapon(_ id: String) async throws
}
