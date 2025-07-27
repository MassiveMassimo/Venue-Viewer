import SwiftUI

struct MapCanvasView: View {
    let viewModel: NavigationViewModel
    @State private var imageDisplayFrame: ImageDisplayFrame?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Map image
                Image("gop_map")
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        updateImageDisplayFrame(containerSize: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        updateImageDisplayFrame(containerSize: newSize)
                    }
                
                // All overlays positioned using proper coordinate transformation
                if let displayFrame = imageDisplayFrame {
                    // Map paths (hallways)
                    MapPathView(hallways: viewModel.hallways, imageDisplayFrame: displayFrame)
                    
                    // Landmark entrance points
                    ForEach(viewModel.landmarks) { landmark in
                        let displayPosition = transformPointToDisplay(
                            point: landmark.entrancePoint,
                            imageDisplayFrame: displayFrame
                        )
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .position(displayPosition)
                    }
                    
                    // Animated route path
                    if !viewModel.mapPathVertices.isEmpty {
                        Path { path in
                            let firstDisplayPoint = transformPointToDisplay(
                                point: viewModel.mapPathVertices.first!.point,
                                imageDisplayFrame: displayFrame
                            )
                            path.move(to: firstDisplayPoint)
                            
                            for vertex in viewModel.mapPathVertices {
                                let displayPoint = transformPointToDisplay(
                                    point: vertex.point,
                                    imageDisplayFrame: displayFrame
                                )
                                path.addLine(to: displayPoint)
                            }
                        }
                        .trim(from: 0, to: viewModel.mapPathDrawnPercentage)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .shadow(color: Color.black.opacity(0.3), radius: 3)
                    }
                    
                    // Starting point marker
                    if viewModel.selectedStartingPoint.entrancePoint != .zero {
                        let startPosition = transformPointToDisplay(
                            point: viewModel.selectedStartingPoint.entrancePoint,
                            imageDisplayFrame: displayFrame
                        )
                        MapMarkerView(
                            position: startPosition,
                            label: "Start",
                            color: .green
                        )
                    }
                    
                    // Destination marker
                    if viewModel.selectedDestination.entrancePoint != .zero {
                        let endPosition = transformPointToDisplay(
                            point: viewModel.selectedDestination.entrancePoint,
                            imageDisplayFrame: displayFrame
                        )
                        MapMarkerView(
                            position: endPosition,
                            label: "End",
                            color: .red
                        )
                    }
                }
            }
            .coordinateSpace(name: "mapContainer")
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Private Functions
    
    /// Updates the image display frame when the container size changes
    private func updateImageDisplayFrame(containerSize: CGSize) {
        let mapSize = getMapImageSize()
        imageDisplayFrame = calculateImageDisplayFrame(
            originalImageSize: mapSize,
            containerSize: containerSize
        )
    }
    
    /// Gets the original map image size (1097×2415)
    private func getMapImageSize() -> CGSize {
        // Return the actual map dimensions
        return CGSize(width: 1097, height: 2415)
    }
}
