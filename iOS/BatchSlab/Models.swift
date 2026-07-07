import Foundation

struct SlabEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var wood: String
    var dimensions: String
    var resin: String
    var stage: String
    var dateCreated: Date = Date()
}
