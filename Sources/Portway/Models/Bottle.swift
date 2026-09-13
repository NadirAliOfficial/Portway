import Foundation

enum WindowsVersion: String, Codable, CaseIterable, Identifiable {
    case win7, win10, win11

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .win7: return "Windows 7"
        case .win10: return "Windows 10"
        case .win11: return "Windows 11"
        }
    }

    /// Value expected by `HKCU\Software\Wine\Version`.
    var registryValue: String { rawValue }
}

struct Bottle: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var windowsVersion: WindowsVersion = .win10
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

    // Custom decoding so bottles saved before `windowsVersion` existed still load.
    enum CodingKeys: String, CodingKey {
        case id, name, windowsVersion, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        windowsVersion = try container.decodeIfPresent(WindowsVersion.self, forKey: .windowsVersion) ?? .win10
    }
}
