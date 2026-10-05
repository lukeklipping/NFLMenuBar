import SwiftUI
import Observation

struct Game : Codable, Identifiable {
    let id: String
    let away: String, home: String
    let awayScore: Int, homeScore: Int
    let status: String
    let isLive: Bool
}

@Observable @MainActor
final class ScoresModel {
    var games: [Game] = []
    private var task: Task<Void, Never>?
    
    var title: String {
        guard let g = games.first(where: \.isLive) else {return "NFL"}
        return "\(g.away) \(g.awayScore)-\(g.homeScore) \(g.home)"
    }
    
    func start(){
        task = Task {
            while !Task.isCancelled{
                if let (data, _) = try? await URLSession.shared.data(from: URL(string: "http://localhost:8080/scores")!),
                   let decoded = try? JSONDecoder().decode([Game].self, from: data){
                    games = decoded
                }
                try? await Task.sleep(for: .seconds(20))
            }
        }
    }
}

@main
struct NFLScoresApp: App {
    @State private var model = ScoresModel()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(model.games) { g in
                    HStack {
                        Text("\(g.away) \(g.awayScore)").frame(width: 70, alignment: .leading)
                        Text("\(g.home) \(g.homeScore)").frame(width: 70, alignment: .leading)
                        Spacer()
                        Text(g.status)
                            .font(.caption)
                            .foregroundStyle(g.isLive ? .red : .secondary)
                    }
                    .font(.system(.body, design: .monospaced))
                }
                Divider()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .padding(12)
            .frame(width: 300)
            .task { model.start() }
        } label: {
            Label(model.title, systemImage: "football.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
