import Foundation

struct Bottle: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    let createdAt: Date

    /// Directory on disk that acts as this bottle's WINEPREFIX.
    var prefixPath: URL {
        Bottle.bottlesRoot.appendingPathComponent(id.uuidString, isDirectory: true)
    }

    static var bottlesRoot: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Portway/Bottles", isDirectory: true)
    }

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
