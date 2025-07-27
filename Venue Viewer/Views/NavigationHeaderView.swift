import SwiftUI

struct NavigationHeaderView: View {
    @Bindable var viewModel: NavigationViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Turn-by-turn instruction text
            HStack {
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue straight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Text("for 50 meters")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Exit navigation button
                Button(action: {
                    viewModel.isInNavigationMode = false
                    viewModel.clearResults()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.thinMaterial)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationHeaderView(viewModel: NavigationViewModel())
        .previewLayout(.sizeThatFits)
}

