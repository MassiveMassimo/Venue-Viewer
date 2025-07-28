import SwiftUI

struct ContentView: View {
    @State private var viewModel = NavigationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top)
                
                // Map
                MapView(viewModel: viewModel)
                    .frame(width: 220)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.vertical, 20)
                
                // Controls Section
                VStack(spacing: 12) {
                    LocationPicker(
                        title: "From:",
                        selection: $viewModel.selectedStartingPoint,
                        landmarks: viewModel.landmarks
                    )
                    
                    LocationPicker(
                        title: "To:",
                        selection: $viewModel.selectedDestination,
                        landmarks: viewModel.landmarks
                    )
                    
                    if viewModel.resultDistance != 0 {
                        RouteInfoView(distance: viewModel.resultDistance)
                            .animation(.easeInOut, value: viewModel.resultDistance)
                    }
                    
                    FindRouteButton(action: viewModel.findRoute)
                        .disabled(!viewModel.canFindRoute)
                        .opacity(viewModel.canFindRoute ? 1 : 0.6)
                        .animation(.easeInOut, value: viewModel.canFindRoute)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LocationTrackingView()) {
                        Image(systemName: "location.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onChange(of: viewModel.selectedDestination) { _, _ in
            viewModel.clearResults()
        }
        .onChange(of: viewModel.selectedStartingPoint) { _, _ in
            viewModel.clearResults()
        }
    }
}

// MARK: - Supporting Views

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Office Navigator")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Find the shortest route in the office!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            NavigationLink(destination: LocationTrackingView()) {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
            
            NavigationLink(destination: BoothListView()) {
                Image(systemName: "map.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
}

struct FindRouteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                Text("Find Route")
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
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
