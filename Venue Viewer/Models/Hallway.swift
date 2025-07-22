import SwiftUI

struct Hallway: Identifiable {
    let id = UUID()
    let start: CGPoint
    let end: CGPoint
    
    var length: CGFloat {
        DistanceFormula(from: start, to: end)
    }
}
