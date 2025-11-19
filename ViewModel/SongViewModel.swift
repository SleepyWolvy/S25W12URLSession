import SwiftUI

@MainActor
@Observable
final class SongViewModel {
    private var _songs: [Song] = []
    var songs: [Song] {
        return _songs
    }
    
    func loadSongs() async {
        let requsetURL = URL(string: SongApiConfig.serverURL)!
        let (data, _) = try! await URLSession.shared.data(from: requsetURL)
        let decoder = JSONDecoder()
        _songs = try! decoder.decode([Song].self, from: data)
    }
    
}
