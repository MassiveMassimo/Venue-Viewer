import SwiftUI

struct StartingPointPickerView: View {
    @Bindable var viewModel: NavigationViewModel
    let onStartingPointSelected: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Select Starting Point")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose where you'd like to start navigating from to reach \(viewModel.selectedDestination.name)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Landmarks list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.landmarks.filter { $0.entrancePoint != .zero }, id: \.id) { landmark in
                            StartingPointRow(
                                landmark: landmark,
                                isSelected: viewModel.selectedStartingPoint.id == landmark.id,
                                isDestination: viewModel.selectedDestination.id == landmark.id
                            ) {
                                selectStartingPoint(landmark)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.isPickerPresented = false
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func selectStartingPoint(_ landmark: Landmark) {
        // Use the new handler method which includes route finding logic
        viewModel.handleStartingPointSelection(landmark)
        
        // Dismiss the picker and trigger callback for immediate navigation transition
        onStartingPointSelected()
        dismiss()
    }
}

// MARK: - Starting Point Row Component

struct StartingPointRow: View {
    let landmark: Landmark
    let isSelected: Bool
    let isDestination: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Landmark icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.title3)
                        .foregroundColor(iconForegroundColor)
                }
                
                // Landmark info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(landmark.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isDestination {
                            Text("(Destination)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("Touch: (\(String(format: "%.0f", landmark.touchPosition.x)), \(String(format: "%.0f", landmark.touchPosition.y)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDestination ? Color(.systemGray6) : Color(.systemBackground))
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
        }
        .disabled(isDestination)
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        if isDestination {
            return "flag.fill"
        } else if isSelected {
            return "figure.walk"
        } else {
            return "mappin.circle.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        if isDestination {
            return .red.opacity(0.1)
        } else if isSelected {
            return .blue.opacity(0.1)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var iconForegroundColor: Color {
        if isDestination {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .secondary
        }
    }
}
