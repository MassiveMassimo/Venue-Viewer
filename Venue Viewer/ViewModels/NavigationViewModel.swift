import SwiftUI
import Observation

@Observable
class NavigationViewModel {
    // MARK: - Properties (no need for @Published)
    var selectedDestination = Landmark(name: "Select destination", labelPosition: .zero, entrancePoint: .zero)
    var selectedStartingPoint = Landmark(name: "Select starting point", labelPosition: .zero, entrancePoint: .zero)
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
        selectedStartingPoint.entrancePoint != .zero &&
        selectedDestination.entrancePoint != .zero
    }
    
    var canFindRoute: Bool {
        hasValidSelection && selectedStartingPoint.name != selectedDestination.name
    }
    
    // MARK: - Public Methods
    func findRoute() {
        guard validateSelection() else { return }
        
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
        // For now, this is a placeholder
        print("Alert: \(title) - \(message)")
    }
}
