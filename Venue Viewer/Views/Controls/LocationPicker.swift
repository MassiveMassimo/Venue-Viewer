import SwiftUI

struct LocationPicker: View {
    let title: String
    @Binding var selection: Landmark
    let landmarks: [Landmark]
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Menu {
                ForEach(landmarks, id: \.id) { landmark in
                    Button(action: {
                        selection = landmark
                    }) {
                        HStack {
                            Text(landmark.name)
                            if selection.id == landmark.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selection.name)
                        .foregroundColor(selection.entrancePoint == .zero ? .secondary : .primary) // Check entrancePoint for navigation validity
                        .lineLimit(1)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
