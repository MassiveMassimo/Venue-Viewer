import SwiftUI

/**
 * Landmark Model - Dual Position Architecture
 * 
 * This model implements a dual-position system for landmarks:
 * 
 * 1. touchPosition: The original coordinate from the JSON data file.
 *    - This represents the visual/logical position of the landmark
 *    - Used for displaying landmark touch areas on the map
 *    - May not align perfectly with navigable paths
 * 
 * 2. entrancePoint: A calculated coordinate representing the nearest accessible point.
 *    - Automatically computed as the closest point on any defined hallway/path
 *    - Used for pathfinding and navigation calculations
 *    - Ensures that routes can be calculated between landmarks
 * 
 * This dual-position approach allows landmarks to be visually placed at their logical 
 * locations while ensuring navigation always routes to accessible pathway points.
 */
struct Landmark: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let touchPosition: CGPoint // The position of the landmark as specified in the JSON data.
    let entrancePoint: CGPoint // The closest point to the landmark on the defined path, calculated for navigation.
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
        lhs.id == rhs.id
    }
}
