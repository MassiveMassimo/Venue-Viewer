import SwiftUI

struct MapPathView: View {
    let hallways: [Hallway]
    let coordinateDisplayFrame: CoordinateDisplayFrame
    
    // Backward compatibility initializer
    init(hallways: [Hallway], imageDisplayFrame: ImageDisplayFrame) {
        self.hallways = hallways
        self.coordinateDisplayFrame = imageDisplayFrame
    }
    
    init(hallways: [Hallway], coordinateDisplayFrame: CoordinateDisplayFrame) {
        self.hallways = hallways
        self.coordinateDisplayFrame = coordinateDisplayFrame
    }
    
    var body: some View {
        Path { path in
            for hallway in hallways {
                let transformedStart = transformPointToDisplay(
                    point: hallway.start,
                    coordinateDisplayFrame: coordinateDisplayFrame
                )
                let transformedEnd = transformPointToDisplay(
                    point: hallway.end,
                    coordinateDisplayFrame: coordinateDisplayFrame
                )
                
                path.move(to: transformedStart)
                path.addLine(to: transformedEnd)
            }
        }
    }
}
