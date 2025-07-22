import SwiftUI

struct MapPathView: View {
    let hallways: [Hallway]
    
    var body: some View {
        Path { path in
            for hallway in hallways {
                path.move(to: hallway.start)
                path.addLine(to: hallway.end)
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
    }
}
