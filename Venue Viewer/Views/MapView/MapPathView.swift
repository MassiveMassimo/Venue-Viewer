import SwiftUI

struct MapPathView: View {
    let hallways: [Hallway]
    let imageDisplayFrame: ImageDisplayFrame
    
    var body: some View {
        Path { path in
            for hallway in hallways {
                let transformedStart = transformPointToDisplay(
                    point: hallway.start,
                    imageDisplayFrame: imageDisplayFrame
                )
                let transformedEnd = transformPointToDisplay(
                    point: hallway.end,
                    imageDisplayFrame: imageDisplayFrame
                )
                
                path.move(to: transformedStart)
                path.addLine(to: transformedEnd)
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
    }
}
