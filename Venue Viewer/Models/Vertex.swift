import SwiftUI

@Observable
class Vertex: Equatable {
    let point: CGPoint
    var distance = CGFloat.infinity
    var heuristic = CGFloat.infinity
    var touchingHallways = [Hallway]()
    var visited = false
    var previousHallway: Hallway?
    
    var fCost: CGFloat {
        distance + heuristic
    }
    
    init(point: CGPoint) {
        self.point = point
    }
    
    static func == (l: Vertex, r: Vertex) -> Bool {
        return l === r
    }
}
