import SwiftUI

struct LandmarkDetailSheet: View {
    let landmark: Landmark?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let landmark = landmark {
                    // Landmark icon and name
                    VStack(spacing: 16) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(landmark.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Location information
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.secondary)
                            Text("Touch Position:")
                                .font(.headline)
                            Spacer()
                        }
                        Text("X: \(String(format: "%.1f", landmark.touchPosition.x)), Y: \(String(format: "%.1f", landmark.touchPosition.y))")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                .foregroundColor(.secondary)
                            Text("Entrance Point:")
                                .font(.headline)
                            Spacer()
                        }
                        Text("X: \(String(format: "%.1f", landmark.entrancePoint.x)), Y: \(String(format: "%.1f", landmark.entrancePoint.y))")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button("Set as Starting Point") {
                            // Action to set as starting point
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Set as Destination") {
                            // Action to set as destination
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(.top, 20)
                    
                } else {
                    // Fallback message
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Landmark Selected")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Landmark Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

