import SwiftUI

struct MapCanvasView: View {
    let viewModel: NavigationViewModel
    
    var body: some View {
        ZStack {
            Image("gop_map")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            // Map paths (hallways)
            MapPathView(hallways: viewModel.hallways)
            
            // Landmark entrance points
            ForEach(viewModel.landmarks) { landmark in
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 6, height: 6)
                    .position(landmark.entrancePoint)
            }
            
            
            
            // Animated route path
            if !viewModel.mapPathVertices.isEmpty {
                Path { path in
                    path.move(to: viewModel.mapPathVertices.first!.point)
                    for vertex in viewModel.mapPathVertices {
                        path.addLine(to: vertex.point)
                    }
                }
                .trim(from: 0, to: viewModel.mapPathDrawnPercentage)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .shadow(color: Color.black.opacity(0.3), radius: 3)
            }
            
            // Starting point marker
            if viewModel.selectedStartingPoint.entrancePoint != .zero {
                MapMarkerView(
                    position: viewModel.selectedStartingPoint.entrancePoint,
                    label: "Start",
                    color: .green
                )
            }
            
            // Destination marker
            if viewModel.selectedDestination.entrancePoint != .zero {
                MapMarkerView(
                    position: viewModel.selectedDestination.entrancePoint,
                    label: "End",
                    color: .red
                )
            }
        }
    }
}
