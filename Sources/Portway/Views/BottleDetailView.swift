import SwiftUI
import UniformTypeIdentifiers

struct BottleDetailView: View {
    var store: BottleStore
    var bottle: Bottle

    @State private var isRunning = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(bottle.name)
                    .font(.title2)
                    .bold()
                Text(bottle.prefixPath.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            HStack(spacing: 12) {
                Button {
                    pickAndRunExecutable()
                } label: {
                    Label("Run .exe…", systemImage: "play.fill")
                }
                .disabled(isRunning)

                Button {
                    NSWorkspace.shared.open(bottle.prefixPath.appendingPathComponent("drive_c"))
                } label: {
                    Label("Open C: Drive", systemImage: "folder")
                }

                if isRunning {
                    ProgressView().controlSize(.small)
                }

                Spacer()

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("Delete Bottle", systemImage: "trash")
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .confirmationDialog(
            "Delete “\(bottle.name)”? This removes its files permanently.",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                store.deleteBottle(bottle)
            }
        }
    }

    private func pickAndRunExecutable() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "exe") ?? .exe]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return }

        isRunning = true
        Task {
            await store.run(exePath: url, in: bottle)
            isRunning = false
        }
    }
}

private extension UTType {
    static var exe: UTType { UTType(importedAs: "com.microsoft.windows-executable") }
}
