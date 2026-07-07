import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [SlabEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("batchslab_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        SlabEntry(name: "Walnut River Table", wood: "Live-edge walnut", dimensions: "72x36in", resin: "3 gal deep pour", stage: "Second flood coat"),
        SlabEntry(name: "Maple Coffee Table", wood: "Spalted maple", dimensions: "48x24in", resin: "1.5 gal", stage: "Sanding"),
        SlabEntry(name: "Oak Serving Board", wood: "White oak", dimensions: "18x10in", resin: "8 oz", stage: "Complete")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(wood: String, dimensions: String, resin: String, stage: String) {
        guard canAddMore else { return }
        let entry = SlabEntry(name: name, wood: wood, dimensions: dimensions, resin: resin, stage: stage)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: SlabEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SlabEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([SlabEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
