import SwiftUI

struct MapCanvasView: View {
    let viewModel: NavigationViewModel
    @State private var coordinateDisplayFrame: CoordinateDisplayFrame?
    private let imageName: String
    
    // Transform states
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var rotation: Angle = .degrees(0)
    
    init(viewModel: NavigationViewModel, imageName: String = "gop_map") {
        self.viewModel = viewModel
        self.imageName = imageName
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The entire map content
                mapContent(in: geometry)
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .offset(offset)
                
                // Gesture overlay
                MapGestureView(
                    scale: $scale,
                    offset: $offset,
                    rotation: $rotation
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    scale = 1.0
                    offset = .zero
                    rotation = .degrees(0)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func mapContent(in geometry: GeometryProxy) -> some View {
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
    
    // MARK: - Private Functions
    
    private func updateCoordinateDisplayFrame(containerSize: CGSize) {
        let imageSize = getImageSize()
        coordinateDisplayFrame = calculateCoordinateDisplayFrame(
            originalSize: imageSize,
            containerSize: containerSize
        )
    }
    
    private func getImageSize() -> CGSize {
        guard let uiImage = UIImage(named: imageName) else {
            return CGSize(width: 1000, height: 1000)
        }
        return uiImage.size
    }
}

// MARK: - Map Gesture View

struct MapGestureView: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var rotation: Angle
    
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.delegate = context.coordinator
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        view.addGestureRecognizer(panGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
        rotationGesture.delegate = context.coordinator
        view.addGestureRecognizer(rotationGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, minScale: minScale, maxScale: maxScale)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let parent: MapGestureView
        let minScale: CGFloat
        let maxScale: CGFloat
        
        private var lastScale: CGFloat = 1.0
        private var lastOffset: CGSize = .zero
        private var lastRotation: Angle = .zero
        private var anchorPoint: CGPoint = .zero
        
        init(parent: MapGestureView, minScale: CGFloat, maxScale: CGFloat) {
            self.parent = parent
            self.minScale = minScale
            self.maxScale = maxScale
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let view = gesture.view else { return }
            
            switch gesture.state {
            case .began:
                lastScale = parent.scale
                anchorPoint = gesture.location(in: view)
                
            case .changed:
                // Calculate new scale
                let newScale = lastScale * gesture.scale
                let clampedScale = min(max(newScale, minScale), maxScale)
                let scaleChange = clampedScale / parent.scale
                
                // Calculate anchor point relative to view center
                let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                let anchorOffset = CGPoint(
                    x: anchorPoint.x - viewCenter.x,
                    y: anchorPoint.y - viewCenter.y
                )
                
                // Adjust offset to zoom into the anchor point
                let offsetAdjustment = CGSize(
                    width: (anchorOffset.x - parent.offset.width) * (1 - scaleChange),
                    height: (anchorOffset.y - parent.offset.height) * (1 - scaleChange)
                )
                
                parent.scale = clampedScale
                parent.offset.width += offsetAdjustment.width
                parent.offset.height += offsetAdjustment.height
                
            default:
                break
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                lastOffset = parent.offset
                
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                parent.offset = CGSize(
                    width: lastOffset.width + translation.x,
                    height: lastOffset.height + translation.y
                )
                
            default:
                break
            }
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let view = gesture.view else { return }
            
            switch gesture.state {
            case .began:
                lastRotation = parent.rotation
                anchorPoint = gesture.location(in: view)
                
            case .changed:
                let rotationDelta = Angle(radians: Double(gesture.rotation))
                let totalRotation = lastRotation + rotationDelta
                
                // Calculate anchor point relative to view center
                let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                let anchorOffset = CGPoint(
                    x: anchorPoint.x - viewCenter.x,
                    y: anchorPoint.y - viewCenter.y
                )
                
                // Calculate how the offset point rotates around the anchor
                let offsetFromAnchor = CGPoint(
                    x: parent.offset.width - anchorOffset.x,
                    y: parent.offset.height - anchorOffset.y
                )
                
                let angleDiff = Double(gesture.rotation) - (parent.rotation - lastRotation).radians
                let cos = cos(angleDiff)
                let sin = sin(angleDiff)
                
                let rotatedOffset = CGPoint(
                    x: offsetFromAnchor.x * cos - offsetFromAnchor.y * sin,
                    y: offsetFromAnchor.x * sin + offsetFromAnchor.y * cos
                )
                
                parent.offset = CGSize(
                    width: rotatedOffset.x + anchorOffset.x,
                    height: rotatedOffset.y + anchorOffset.y
                )
                parent.rotation = totalRotation
                
            default:
                break
            }
        }
    }
}
