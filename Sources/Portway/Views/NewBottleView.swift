import SwiftUI

struct NewBottleView: View {
    var store: BottleStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isCreating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Bottle")
                .font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .disabled(isCreating)
                Button("Create") {
                    Task {
                        isCreating = true
                        await store.createBottle(named: name)
                        isCreating = false
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
            }
        }
        .padding(20)
        .frame(width: 320)
        .overlay {
            if isCreating {
                ProgressView("Setting up bottle…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
