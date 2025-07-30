import SwiftUI

struct LandmarkTouchAreaView: View {
    let landmark: Landmark
    let position: CGPoint
    let onTap: (Landmark) -> Void
    
    var body: some View {
        // Larger invisible tappable area (50x50) with right offset
        Rectangle()
            .fill(Color.white.opacity(0.001)) // Nearly invisible but still tappable
            .frame(width: 50, height: 50)
            .position(x: position.x + 15, y: position.y) // Shift 15 points to the right
            .onTapGesture {
                onTap(landmark)
            }
    }
}
