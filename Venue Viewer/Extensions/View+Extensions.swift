import SwiftUI

extension View {
    /// Applies a card-like styling to any view
    func cardStyle(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    /// Conditional modifier - applies a modifier only if condition is true
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Hides the view based on a condition
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
    
    /// Adds a subtle border to the view
    func subtleBorder(color: Color = .gray, width: CGFloat = 1, cornerRadius: CGFloat = 8) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color.opacity(0.2), lineWidth: width)
        )
    }
    
    /// Adds a loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
        )
    }
}

// MARK: - Animation Extensions

extension Animation {
    static let mapAnimation = Animation.easeInOut(duration: 0.5)
    static let buttonTap = Animation.easeInOut(duration: 0.1)
    static let routeDrawing = Animation.easeInOut(duration: 1.0)
}

// MARK: - Color Extensions

extension Color {
    static let mapBackground = Color(.systemGray6)
    static let pathColor = Color.gray.opacity(0.3)
    static let routeColor = Color.blue
    static let startMarkerColor = Color.green
    static let endMarkerColor = Color.red
    static let landmarkDotColor = Color.orange.opacity(0.2)
}

// MARK: - Shape Extensions

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
