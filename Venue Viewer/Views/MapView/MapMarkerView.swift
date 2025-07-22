import SwiftUI

struct MapMarkerView: View {
    let position: CGPoint
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.9))
                )
        }
        .position(position)
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}
