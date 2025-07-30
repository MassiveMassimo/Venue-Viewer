import SwiftUI
import Observation

@Observable
class NavigationViewModel {
    // MARK: - Properties (no need for @Published)
    var selectedDestination = Landmark(name: "Select destination", touchPosition: .zero, entrancePoint: .zero) // User-selectable destination landmark
    var selectedStartingPoint = Landmark(name: "Select starting point", touchPosition: .zero, entrancePoint: .zero) // User-selectable starting landmark
    var isInNavigationMode: Bool = false
    var isLandmarkDetailSheetPresented: Bool = false
    var selectedLandmark: Landmark?
    var isPickerPresented: Bool = false
    var resultDistance: CGFloat = 0
    var mapPathVertices: [Vertex] = []
    var mapPathDrawnPercentage: CGFloat = 0
    
    // MARK: - Dependencies
    private let pathfindingService: PathfindingService
    private let mapData: MapData
    
    init(pathfindingService: PathfindingService = PathfindingService(),
         mapData: MapData = .shared) {
        self.pathfindingService = pathfindingService
        self.mapData = mapData
    }
    
    // MARK: - Computed Properties
    var landmarks: [Landmark] {
        mapData.sortedLandmarks
    }
    
    var hallways: [Hallway] {
        mapData.hallways
    }
    
    var hasValidSelection: Bool {
        // Check entrancePoint validity for navigation - ensures landmarks have calculated navigation points
        selectedStartingPoint.entrancePoint != .zero &&
        selectedDestination.entrancePoint != .zero
    }
    
    var canFindRoute: Bool {
        hasValidSelection && selectedStartingPoint.name != selectedDestination.name
    }
    
    // MARK: - Public Methods
    func findRoute() {
        guard validateSelection() else { return }
        
        // Use entrancePoint coordinates for pathfinding - these are guaranteed to be on navigable paths
        let startPoint = selectedStartingPoint.entrancePoint
        let endPoint = selectedDestination.entrancePoint
        
        if let route = pathfindingService.findShortestRoute(from: startPoint, to: endPoint) {
            // First, set the path and distance without animation
            resultDistance = route.distance
            mapPathVertices = route.path
            
            // Reset the path drawing percentage to 0 (ensuring it's actually 0)
            mapPathDrawnPercentage = 0
            
            // Use a small delay to ensure the path is set before starting the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.routeDrawing) {
                    self.mapPathDrawnPercentage = 1
                }
            }
        }
    }
    
    func clearResults() {
        withAnimation {
            resultDistance = 0
            mapPathVertices.removeAll()
            mapPathDrawnPercentage = 0
        }
    }
    
    func exitNavigation() {
        // Reset navigation mode
        isInNavigationMode = false
        
        // Clear all results and paths
        clearResults()
        
        // Reset selected landmarks if needed
        selectedStartingPoint = Landmark(name: "Select starting point", touchPosition: .zero, entrancePoint: .zero)
        selectedDestination = Landmark(name: "Select destination", touchPosition: .zero, entrancePoint: .zero)
        
        // Clear selected landmark to avoid conflicts
        selectedLandmark = nil
        
        // Notify to show controls sheet again
        onSheetStateChanged?(.controls)
    }
    
    // MARK: - Private Methods
    private func validateSelection() -> Bool {
        guard hasValidSelection else {
            showAlert(title: "Select locations", message: "Please select both a starting point and destination")
            return false
        }
        
        guard selectedStartingPoint.name != selectedDestination.name else {
            showAlert(title: "Same location", message: "Starting point and destination cannot be the same")
            return false
        }
        
        return true
    }
    
    private func showAlert(title: String, message: String) {
        // In production, you'd use a proper alert system
        // For now, this is silently handled
    }
    
    // MARK: - Sheet Management
    
    /// Closure to notify parent view about sheet state changes
    var onSheetStateChanged: ((SheetState) -> Void)?
    
    /// Closure to handle landmark detail sheet dismissal
    var onLandmarkDetailDismissed: (() -> Void)?
    
    func closeControlsAndShowLandmarkDetail() {
        // Notify parent view about the sheet transition
        onSheetStateChanged?(.landmarkDetail)
    }
    
    func dismissLandmarkDetailSheet() {
        // Clear the selected landmark to trigger sheet dismissal
        selectedLandmark = nil
        
        // Notify parent view about the dismissal
        onLandmarkDetailDismissed?()
        
        // Return to controls sheet
        onSheetStateChanged?(.controls)
    }
    
    func handleSheetDismissal() {
        // Reset any transient state when sheets are dismissed
        isPickerPresented = false
    }
    
    // MARK: - Picker Selection Logic
    func handleStartingPointSelection(_ landmark: Landmark) {
        // Update the selected starting point
        selectedStartingPoint = landmark
        
        // Set navigation mode to true
        isInNavigationMode = true
        
        // Dismiss all presented sheets
        isPickerPresented = false
        selectedLandmark = nil
        onSheetStateChanged?(.none)
        
        // Clear any existing routes
        clearResults()
        
        // Check if we have both starting point and destination selected
        // and they are different landmarks with valid entrance points
        if canFindRoute {
            // Automatically trigger route finding
            findRoute()
        }
    }
    
    func dismissPickerAndDetailSheet() {
        // Dismiss the picker
        isPickerPresented = false
        
        // Clear the selected landmark to dismiss the detail sheet
        selectedLandmark = nil
    }
}
