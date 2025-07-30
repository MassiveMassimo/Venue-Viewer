import SwiftUI

struct NavigationBottomSheetView: View {
    @Bindable var viewModel: NavigationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Navigation info section
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                    Text("Navigation Active")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distance Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.resultDistance > 0 ? "\(String(format: "%.1f", viewModel.resultDistance))m" : "Calculating...")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Est. Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(calculateRemainingTime())
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Exit Navigation Button
            Button(action: { viewModel.exitNavigation() }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Exit Navigation")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
                .shadow(color: Color.red.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .padding(20)
    }
    
    private func calculateRemainingTime() -> String {
        guard viewModel.resultDistance > 0 else {
            return "Calculating..."
        }
        
        // Estimate walking time based on average walking speed of 1.4 m/s (5 km/h)
        let walkingSpeed: CGFloat = 1.4 // meters per second
        let timeInSeconds = viewModel.resultDistance / walkingSpeed
        
        if timeInSeconds < 60 {
            return "\(Int(timeInSeconds))s"
        } else {
            let minutes = Int(timeInSeconds / 60)
            let seconds = Int(timeInSeconds.truncatingRemainder(dividingBy: 60))
            return "\(minutes)m \(seconds)s"
        }
    }
}

#Preview {
    NavigationBottomSheetView(viewModel: NavigationViewModel())
}
