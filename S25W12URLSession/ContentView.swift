import SwiftUI

//  메인 탭
struct ContentView: View {
    var body: some View {
        TabView {
            // 탭: 노래 관리
            SongView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Songs")
                }
            
            // 탭: 무기 관리
            WeaponView()
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("Weapons")
                }
        }
    }
}


//  노래(Song) 관련 뷰


struct SongView: View {
    @State private var viewModel = SongViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            SongListView(viewModel: viewModel)
                .navigationDestination(for: Song.self) { song in
                    SongDetailView(song: song)
                }
                .navigationTitle("노래")
                .task { await viewModel.loadSongs() }
                .refreshable { await viewModel.loadSongs() }
                .toolbar {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    SongAddView(viewModel: viewModel)
                }
        }
    }
}

struct SongListView: View {
    let viewModel: SongViewModel
    
    func deleteSong(offsets: IndexSet) {
        Task {
            for index in offsets {
                let song = viewModel.songs[index]
                await viewModel.deleteSong(song)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                NavigationLink(value: song) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.singer)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onDelete(perform: deleteSong)
        }
    }
}

struct SongDetailView: View {
    let song: Song

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(song.singer)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(song.rating)점")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 10)
                
                Divider()
                
                Text("가사")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                Text(song.lyrics ?? "(가사 없음)")
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(song.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SongAddView: View {
    let viewModel: SongViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var title = ""
    @State var singer = ""
    @State var rating = 3
    @State var lyrics = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("노래 정보 *")) {
                    TextField("제목", text: $title)
                    TextField("가수", text: $singer)
                }
                
                Section(header: Text("선호도")) {
                    Picker("별점", selection: $rating) {
                        ForEach(1...5, id: \.self) { score in
                            Text("\(score)점").tag(score)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("가사")) {
                    TextEditor(text: $lyrics)
                        .frame(height: 150)
                }
            }
            .navigationTitle("노래 추가")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.addSong(
                                Song(id: UUID(), title: title, singer: singer, rating: rating, lyrics: lyrics)
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || singer.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
}


// 무기 관련 뷰


struct WeaponView: View {
    @State private var viewModel = WeaponViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            WeaponListView(viewModel: viewModel)
                .navigationDestination(for: Weapon.self) { weapon in
                    WeaponDetailView(weapon: weapon)
                }
                .navigationTitle("무기")
                .task { await viewModel.loadWeapons() }
                .refreshable { await viewModel.loadWeapons() }
                .toolbar {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    WeaponAddView(viewModel: viewModel)
                }
        }
    }
}

struct WeaponListView: View {
    let viewModel: WeaponViewModel
    
    func deleteWeapon(offsets: IndexSet) {
        Task {
            for index in offsets {
                let weapon = viewModel.weapons[index]
                await viewModel.deleteWeapon(weapon)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.weapons) { weapon in
                NavigationLink(value: weapon) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(weapon.name)
                                .font(.headline)
                            
                            HStack {
                                if let country = weapon.country {
                                    Text(country)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                if let caliber = weapon.caliber {
                                    Text(caliber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                        if let year = weapon.year {
                            Text(String(year))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onDelete(perform: deleteWeapon)
        }
        .overlay {
            if viewModel.weapons.isEmpty {
                ContentUnavailableView("무기가 없습니다", systemImage: "shield.slash")
            }
        }
    }
}

struct WeaponDetailView: View {
    let weapon: Weapon

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 이름과 제조국
                VStack(alignment: .leading, spacing: 5) {
                    Text(weapon.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let country = weapon.country {
                        Label(country, systemImage: "flag.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 10)
                
                Divider()
                
                // 상세 정보
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 15) {
                    if let caliber = weapon.caliber {
                        GridRow {
                            Text("사용 탄약")
                                .fontWeight(.semibold)
                            Text(caliber)
                        }
                    }
                    
                    if let year = weapon.year {
                        GridRow {
                            Text("개발/배치")
                                .fontWeight(.semibold)
                            Text("\(String(year))년")
                        }
                    }
                    
                    if let created = weapon.createdAt {
                        GridRow {
                            Text("데이터 생성일")
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            Text(created)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(weapon.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeaponAddView: View {
    let viewModel: WeaponViewModel
    @Environment(\.dismiss) var dismiss
    
    // 입력 필드
    @State private var name = ""
    @State private var country = ""
    @State private var caliber = ""
    @State private var yearString = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("기본 정보 *")) {
                    TextField("무기 이름 (예: AK-47)", text: $name)
                    TextField("제조국 (예: 소련)", text: $country)
                }
                
                Section(header: Text("제원 상세")) {
                    TextField("구경 (예: 7.62x39mm)", text: $caliber)
                    
                    TextField("개발 년도 (예: 1947)", text: $yearString)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("무기 추가")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("저장") {
                                    Task {
                                        let yearInt = Int(yearString)
                                        let finalCountry = country.isEmpty ? nil : country
                                        let finalCaliber = caliber.isEmpty ? nil : caliber
                                        
                                       
                                        let newWeapon = Weapon(
                                            id: Int(Date().timeIntervalSince1970), 
                                            name: name,
                                            year: yearInt,
                                            country: finalCountry,
                                            caliber: finalCaliber,
                                            createdAt: nil
                                        )
                                        
                                        await viewModel.addWeapon(newWeapon)
                                        dismiss()
                                    }
                                }
                                .disabled(name.isEmpty)
                            }
            // ~
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
