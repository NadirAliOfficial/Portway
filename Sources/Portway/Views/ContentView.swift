import SwiftUI

struct ContentView: View {
    var store: BottleStore

    @State private var selection: Bottle.ID?
    @State private var showingNewBottleSheet = false

    var body: some View {
        NavigationSplitView {
            List(store.bottles, selection: $selection) { bottle in
                Text(bottle.name).tag(bottle.id)
            }
            .navigationTitle("Portway")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingNewBottleSheet = true
                    } label: {
                        Label("New Bottle", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let id = selection, let bottle = store.bottles.first(where: { $0.id == id }) {
                BottleDetailView(store: store, bottle: bottle)
            } else {
                ContentUnavailableView(
                    "No Bottle Selected",
                    systemImage: "shippingbox",
                    description: Text("Create a bottle to install and run a Windows app.")
                )
            }
        }
        .frame(minWidth: 700, minHeight: 420)
        .sheet(isPresented: $showingNewBottleSheet) {
            NewBottleView(store: store)
        }
        .alert("Error", isPresented: Binding(
            get: { store.lastError != nil },
            set: { if !$0 { store.lastError = nil } }
        )) {
            Button("OK") { store.lastError = nil }
        } message: {
            Text(store.lastError ?? "")
        }
    }
}
