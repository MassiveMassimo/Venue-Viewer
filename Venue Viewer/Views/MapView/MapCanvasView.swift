import SwiftUI

struct MapCanvasView: View {
    let viewModel: NavigationViewModel
    @State private var coordinateDisplayFrame: CoordinateDisplayFrame?
    private let imageName: String
    
    init(viewModel: NavigationViewModel, imageName: String = "gop_map") {
        self.viewModel = viewModel
        self.imageName = imageName
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        updateCoordinateDisplayFrame(containerSize: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        updateCoordinateDisplayFrame(containerSize: newSize)
                    }
                
                // All overlays positioned using proper coordinate transformation
                if let displayFrame = coordinateDisplayFrame {
                    // Coordinate paths (hallways)
                    MapPathView(hallways: viewModel.hallways, coordinateDisplayFrame: displayFrame)
                    
                    // Landmark entrance points
                    ForEach(viewModel.landmarks) { landmark in
                        let displayPosition = transformPointToDisplay(
                            point: landmark.entrancePoint,
                            coordinateDisplayFrame: displayFrame
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
                                coordinateDisplayFrame: displayFrame
                            )
                            path.move(to: firstDisplayPoint)
                            
                            for vertex in viewModel.mapPathVertices {
                                let displayPoint = transformPointToDisplay(
                                    point: vertex.point,
                                    coordinateDisplayFrame: displayFrame
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
                            coordinateDisplayFrame: displayFrame
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
                            coordinateDisplayFrame: displayFrame
                        )
                        MapMarkerView(
                            position: endPosition,
                            label: "End",
                            color: .red
                        )
                    }
                }
            }
            .coordinateSpace(name: "coordinateContainer")
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Private Functions
    
    /// Updates the coordinate display frame when the container size changes
    private func updateCoordinateDisplayFrame(containerSize: CGSize) {
        let imageSize = getImageSize()
        coordinateDisplayFrame = calculateCoordinateDisplayFrame(
            originalSize: imageSize,
            containerSize: containerSize
        )
    }
    
    /// Gets the original image size dynamically
    private func getImageSize() -> CGSize {
        guard let uiImage = UIImage(named: imageName) else {
            // Fallback to a reasonable default if image not found
            return CGSize(width: 1000, height: 1000)
        }
        return uiImage.size
    }
}
