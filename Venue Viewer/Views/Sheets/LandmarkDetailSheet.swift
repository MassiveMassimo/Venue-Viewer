import SwiftUI

struct LandmarkDetailSheet: View {
    let landmark: Landmark?
    let viewModel: NavigationViewModel?
    @Environment(\.dismiss) private var dismiss
    @State private var isPickerPresented = false
    
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
                        NavigateButton(
                            landmark: landmark,
                            viewModel: viewModel,
                            onNavigate: {
                                dismiss()
                            }
                        )
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
                        // Use the ViewModel's dismissal method for proper coordination
                        viewModel?.dismissLandmarkDetailSheet()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.isPickerPresented ?? false },
                set: { newValue in viewModel?.isPickerPresented = newValue }
            )) {
                if let viewModel = viewModel {
                    StartingPointPickerView(
                        viewModel: viewModel,
                        onStartingPointSelected: {
                            // Use the ViewModel's coordinated dismissal method
                            viewModel.dismissPickerAndDetailSheet()
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Navigate Button Component

struct NavigateButton: View {
    let landmark: Landmark
    let viewModel: NavigationViewModel?
    let onNavigate: () -> Void
    
    var body: some View {
        Button(action: {
            guard let viewModel = viewModel else { return }
            
            // Set the current landmark as the destination
            viewModel.selectedDestination = landmark
            
            // Clear any existing routes
            viewModel.clearResults()
            
            // Show the picker for starting point selection
            viewModel.isPickerPresented = true
        }) {
            HStack {
                Image(systemName: "location.north.line.fill")
                Text("Navigate")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .font(.system(size: 18))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .disabled(landmark.entrancePoint == .zero)
        .opacity(landmark.entrancePoint == .zero ? 0.6 : 1.0)
    }
}
