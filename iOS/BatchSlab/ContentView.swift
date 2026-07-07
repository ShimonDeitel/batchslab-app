import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEntry: SlabEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entry_row_\(entry.name)")
                        .listRowBackground(Theme.cardBackground)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Batch Slab")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settings_button")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("add_button")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntrySheet(isPresented: $showingAdd)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EditEntrySheet(entry: entry)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(isPresented: $showingPaywall)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(isPresented: $showingSettings)
                    .environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: SlabEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(entry.wood)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.bodyFont)
        }
    }
}

struct AddEntrySheet: View {
    @EnvironmentObject var store: Store
    @Binding var isPresented: Bool
    @State private var draftName: String = ""
    @State private var draftWood: String = ""
    @State private var draftDimensions: String = ""
    @State private var draftResin: String = ""
    @State private var draftStage: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Slab Details") {
                    TextField("Name", text: $draftName)
                        .accessibilityIdentifier("field_name")
                    TextField("Wood", text: $draftWood)
                .accessibilityIdentifier("field_wood")
            TextField("Dimensions", text: $draftDimensions)
                .accessibilityIdentifier("field_dimensions")
            TextField("Resin", text: $draftResin)
                .accessibilityIdentifier("field_resin")
            TextField("Stage", text: $draftStage)
                .accessibilityIdentifier("field_stage")
                }
            }
            .navigationTitle("New Slab")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .accessibilityIdentifier("cancel_add_button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(name: draftName, wood: draftWood, dimensions: draftDimensions, resin: draftResin, stage: draftStage)
                        isPresented = false
                    }
                    .accessibilityIdentifier("save_add_button")
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

struct EditEntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State var entry: SlabEntry

    var body: some View {
        NavigationStack {
            Form {
                Section("Slab Details") {
                    TextField("Name", text: $entry.name)
                        .accessibilityIdentifier("edit_field_name")
                    TextField("Wood", text: $entry.wood)
                    TextField("Dimensions", text: $entry.dimensions)
                    TextField("Resin", text: $entry.resin)
                    TextField("Stage", text: $entry.stage)
                }
                Section {
                    Button(role: .destructive) {
                        store.delete(entry)
                        dismiss()
                    } label: {
                        Text("Delete")
                    }
                    .accessibilityIdentifier("delete_entry_button")
                }
            }
            .navigationTitle("Edit Slab")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.update(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("save_edit_button")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
