import SwiftUI

struct LandmarkTouchAreaView: View {
    let landmark: Landmark
    let position: CGPoint
    let onTap: (Landmark) -> Void
    
    var body: some View {
        // Invisible tappable area (30x30)
        Rectangle()
            .fill(Color.clear)
            .frame(width: 30, height: 30)
            .overlay(
                // The actual visible orange circle as touch target
                Circle()
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)
            )
            .position(position)
            .onTapGesture {
                onTap(landmark)
            }
    }
}
