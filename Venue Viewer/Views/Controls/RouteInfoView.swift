import SwiftUI

struct RouteInfoView: View {
    let distance: CGFloat
    
    private var distanceInMeters: String {
        numberToMeters(number: distance)
    }
    
    private var timeInSeconds: String {
        numberToSeconds(number: distance)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label("Route Information", systemImage: "route")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "ruler")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Text("\(distanceInMeters) meters")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Label {
                        Text("Est. Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Text("~\(timeInSeconds) seconds")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }
}
