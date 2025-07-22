import SwiftUI

struct Landmark: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let labelPosition: CGPoint // Position of the text label
    let entrancePoint: CGPoint // Calculated nearest point on path
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
        lhs.id == rhs.id
    }
}
