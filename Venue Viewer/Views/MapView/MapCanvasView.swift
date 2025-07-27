import SwiftUI

// MARK: - PassThroughUIView
// This UIView subclass allows touches to pass through to SwiftUI views underneath
// while still capturing gestures when needed for map interactions
class PassThroughUIView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        // If the hit test finds this view (not a subview), check if any gestures
        // should handle this touch. If not, return nil to pass through.
        if hitView == self {
            // Check if any of our gesture recognizers want this touch
            for gestureRecognizer in gestureRecognizers ?? [] {
                if gestureRecognizer.isEnabled {
                    // For pan gestures, only capture if it's a multi-touch or long press
                    if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                        // Allow single quick taps to pass through
                        if event?.allTouches?.count == 1 {
                            continue
                        }
                    }
                    // Pinch and rotation gestures need multiple touches
                    else if gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer {
                        if (event?.allTouches?.count ?? 0) < 2 {
                            continue
                        }
                    }
                    return self
                }
            }
            // No gesture wants this touch, pass it through
            return nil
        }
        
        return hitView
    }
}

struct MapCanvasView: View {
    let viewModel: NavigationViewModel
    @State private var coordinateDisplayFrame: CoordinateDisplayFrame?
    private let imageName: String
    
    // Transform states
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var rotation: Angle = .degrees(0)
    
    // Alert states
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(viewModel: NavigationViewModel, imageName: String = "gop_map") {
        self.viewModel = viewModel
        self.imageName = imageName
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The map content (without landmarks)
                mapContentWithoutLandmarks(in: geometry)
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .offset(offset)
                
                // Gesture overlay
                MapGestureView(
                    scale: $scale,
                    offset: $offset,
                    rotation: $rotation
                )
                
                // Landmark touch areas - positioned on top and transformed separately
                landmarkOverlays(in: geometry)
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
        .alert("Landmark Tapped", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    @ViewBuilder
    private func mapContentWithoutLandmarks(in geometry: GeometryProxy) -> some View {
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
    
    @ViewBuilder
    private func landmarkOverlays(in geometry: GeometryProxy) -> some View {
        // Landmark touch areas - positioned on top and manually transformed
        if let displayFrame = coordinateDisplayFrame {
            ForEach(viewModel.landmarks) { landmark in
                let basePosition = transformPointToDisplay(
                    point: landmark.entrancePoint,
                    coordinateDisplayFrame: displayFrame
                )
                
                // Apply the same transformations as the map content
                let transformedPosition = applyTransformations(to: basePosition, in: geometry)
                
                LandmarkTouchAreaView(
                    landmark: landmark,
                    position: transformedPosition,
                    onTap: handleLandmarkTap
                )
            }
        }
    }
    
    private func applyTransformations(to point: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
        // Step 1: Translate point to origin (center-based coordinates)
        let translatedPoint = CGPoint(
            x: point.x - center.x,
            y: point.y - center.y
        )
        
        // Step 2: Apply scale
        let scaledPoint = CGPoint(
            x: translatedPoint.x * scale,
            y: translatedPoint.y * scale
        )
        
        // Step 3: Apply rotation
        let rotationRadians = rotation.radians
        let cosAngle = cos(rotationRadians)
        let sinAngle = sin(rotationRadians)
        
        let rotatedPoint = CGPoint(
            x: scaledPoint.x * cosAngle - scaledPoint.y * sinAngle,
            y: scaledPoint.x * sinAngle + scaledPoint.y * cosAngle
        )
        
        // Step 4: Translate back to screen coordinates and apply offset
        let finalPoint = CGPoint(
            x: rotatedPoint.x + center.x + offset.width,
            y: rotatedPoint.y + center.y + offset.height
        )
        
        return finalPoint
    }
    
    // MARK: - Private Functions
    
    private func handleLandmarkTap(_ landmark: Landmark) {
        print("🔥 handleLandmarkTap called for: \(landmark.name)")
        
        // Show alert with landmark information
        alertMessage = "You tapped on \(landmark.name)"
        showingAlert = true
        
        // Update the view model or application state as needed
        if viewModel.selectedStartingPoint.entrancePoint == .zero {
            viewModel.selectedStartingPoint = landmark
        } else if viewModel.selectedDestination.entrancePoint == .zero {
            viewModel.selectedDestination = landmark
        } else {
            viewModel.selectedStartingPoint = landmark
        }
    }
    
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
        let view = PassThroughUIView()
        view.backgroundColor = .clear
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.delegate = context.coordinator
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        // Add a small delay to allow quick taps to be handled by landmark buttons first
        panGesture.delaysTouchesBegan = true
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
            switch gesture.state {
            case .began:
                lastRotation = parent.rotation
                
            case .changed:
                parent.rotation = lastRotation + Angle(radians: Double(gesture.rotation))
                
            default:
                break
            }
        }
    }
}
