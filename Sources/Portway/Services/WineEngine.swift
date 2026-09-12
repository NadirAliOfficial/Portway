import Foundation

enum WineEngineError: LocalizedError {
    case engineNotFound
    case processFailed(command: String, exitCode: Int32, stderr: String)
    case launchFailed(String)

    var errorDescription: String? {
        switch self {
        case .engineNotFound:
            return "No Wine engine was found. Install Game Porting Toolkit (or another Wine build) first."
        case .processFailed(let command, let exitCode, let stderr):
            let trimmed = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            let detail = trimmed.isEmpty ? "no output" : trimmed
            return "'\(command)' exited with code \(exitCode): \(detail)"
        case .launchFailed(let reason):
            return "Failed to launch process: \(reason)"
        }
    }
}

/// Thread-safe accumulator for data read off a pipe's readability handler,
/// which fires on a background dispatch queue concurrently with the caller.
final class SendableBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var _data = Data()

    var data: Data {
        lock.lock()
        defer { lock.unlock() }
        return _data
    }

    func append(_ chunk: Data) {
        lock.lock()
        defer { lock.unlock() }
        _data.append(chunk)
    }
}

/// Wraps the underlying Wine binary. Responsible only for locating the engine
/// and running processes against a given WINEPREFIX — no UI, no bottle bookkeeping.
struct WineEngine {
    let binaryPath: String

    private static let candidatePaths = [
        "/Applications/Game Porting Toolkit.app/Contents/Resources/wine/bin/wine64",
        "/usr/local/bin/wine64",
        "/opt/homebrew/bin/wine64",
    ]

    static func locate() -> WineEngine? {
        let fm = FileManager.default
        for path in candidatePaths where fm.isExecutableFile(atPath: path) {
            return WineEngine(binaryPath: path)
        }
        return nil
    }

    /// Initializes a fresh WINEPREFIX at the given path (creates the C: drive layout).
    func initPrefix(at prefixPath: URL) async throws {
        try FileManager.default.createDirectory(at: prefixPath, withIntermediateDirectories: true)
        _ = try await run(arguments: ["wineboot", "--init"], prefixPath: prefixPath)
    }

    /// Runs an arbitrary .exe inside the given prefix. Returns once the process exits.
    @discardableResult
    func runExecutable(_ exePath: URL, prefixPath: URL) async throws -> Int32 {
        try await run(arguments: [exePath.path], prefixPath: prefixPath)
    }

    @discardableResult
    private func run(arguments: [String], prefixPath: URL) async throws -> Int32 {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: binaryPath)
            process.arguments = arguments

            var env = ProcessInfo.processInfo.environment
            env["WINEPREFIX"] = prefixPath.path
            env["WINEDEBUG"] = "-all"
            process.environment = env

            let stderrPipe = Pipe()
            process.standardError = stderrPipe

            let stderrBuffer = SendableBuffer()
            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                stderrBuffer.append(handle.availableData)
            }

            process.terminationHandler = { proc in
                stderrPipe.fileHandleForReading.readabilityHandler = nil
                let stderrText = String(data: stderrBuffer.data, encoding: .utf8) ?? ""
                if proc.terminationStatus == 0 {
                    continuation.resume(returning: 0)
                } else {
                    continuation.resume(throwing: WineEngineError.processFailed(
                        command: arguments.joined(separator: " "),
                        exitCode: proc.terminationStatus,
                        stderr: stderrText
                    ))
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: WineEngineError.launchFailed(error.localizedDescription))
            }
        }
    }
}
