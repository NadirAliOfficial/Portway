import Foundation
import Observation

@Observable
final class BottleStore {
    private(set) var bottles: [Bottle] = []
    var lastError: String?

    private let indexURL: URL

    init() {
        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Portway", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        self.indexURL = supportDir.appendingPathComponent("bottles.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: indexURL) else {
            bottles = []
            return
        }
        do {
            bottles = try JSONDecoder().decode([Bottle].self, from: data)
        } catch {
            lastError = "Could not read saved bottles: \(error.localizedDescription)"
            bottles = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(bottles)
            try data.write(to: indexURL, options: .atomic)
        } catch {
            lastError = "Could not save bottle list: \(error.localizedDescription)"
        }
    }

    @MainActor
    func createBottle(named name: String) async {
        guard let engine = WineEngine.locate() else {
            lastError = WineEngineError.engineNotFound.localizedDescription
            return
        }
        let bottle = Bottle(name: name)
        do {
            try await engine.initPrefix(at: bottle.prefixPath)
            bottles.append(bottle)
            persist()
        } catch {
            lastError = error.localizedDescription
            try? FileManager.default.removeItem(at: bottle.prefixPath)
        }
    }

    @MainActor
    func deleteBottle(_ bottle: Bottle) {
        try? FileManager.default.removeItem(at: bottle.prefixPath)
        bottles.removeAll { $0.id == bottle.id }
        persist()
    }

    @MainActor
    func run(exePath: URL, in bottle: Bottle) async {
        guard let engine = WineEngine.locate() else {
            lastError = WineEngineError.engineNotFound.localizedDescription
            return
        }
        do {
            try await engine.runExecutable(exePath, prefixPath: bottle.prefixPath)
        } catch {
            lastError = error.localizedDescription
        }
    }

    @MainActor
    func setWindowsVersion(_ version: WindowsVersion, for bottle: Bottle) async {
        guard let engine = WineEngine.locate() else {
            lastError = WineEngineError.engineNotFound.localizedDescription
            return
        }
        do {
            try await engine.setWindowsVersion(version, prefixPath: bottle.prefixPath)
            guard let index = bottles.firstIndex(where: { $0.id == bottle.id }) else { return }
            bottles[index].windowsVersion = version
            persist()
        } catch {
            lastError = error.localizedDescription
        }
    }

    @MainActor
    func installCommonRuntimes(for bottle: Bottle) async {
        guard let engine = WineEngine.locate() else {
            lastError = WineEngineError.engineNotFound.localizedDescription
            return
        }
        do {
            try await engine.installCommonRuntimes(prefixPath: bottle.prefixPath)
        } catch {
            lastError = error.localizedDescription
        }
    }
}
