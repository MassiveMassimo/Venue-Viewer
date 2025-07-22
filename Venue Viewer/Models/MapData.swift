import SwiftUI

// MARK: - JSON Data Models

struct MapDataJSON: Codable {
    let configuration: MapConfigurationJSON
    let pathSegments: [PathSegmentJSON]
    let landmarks: [LandmarkJSON]
}

struct MapConfigurationJSON: Codable {
    let scaleFactor: CGFloat
    let nearPointTolerance: CGFloat
    let linePointTolerance: CGFloat
}

struct PathSegmentJSON: Codable {
    let start: PointJSON
    let end: PointJSON
}

struct LandmarkJSON: Codable {
    let name: String
    let position: PointJSON
}

struct PointJSON: Codable {
    let x: CGFloat
    let y: CGFloat
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

// MARK: - Map Configuration

struct MapConfiguration {
    let scaleFactor: CGFloat
    let nearPointTolerance: CGFloat
    let linePointTolerance: CGFloat
    
    static let `default` = MapConfiguration(
        scaleFactor: 0.25,
        nearPointTolerance: 1.0,
        linePointTolerance: 3.0
    )
}

// MARK: - Map Data Provider

enum MapDataError: Error {
    case fileNotFound
    case invalidData
    case decodingError(Error)
}

class MapData {
    // Singleton instance
    static let shared = MapData()
    
    // Configuration
    private(set) var configuration: MapConfiguration = .default
    
    // Cached data
    private(set) var hallways: [Hallway] = []
    private(set) var landmarks: [Landmark] = []
    
    // Loading state
    private(set) var isLoaded = false
    private(set) var loadError: MapDataError?
    
    private init() {
        loadMapData()
    }
    
    // MARK: - Data Loading
    
    func loadMapData(from filename: String = "map_data") {
        do {
            let mapData = try loadJSONFile(filename: filename)
            processMapData(mapData)
            isLoaded = true
            loadError = nil
        } catch {
            loadError = error as? MapDataError ?? .invalidData
            print("Failed to load map data: \(error)")
            // Fallback to default empty data
            hallways = []
            landmarks = []
        }
    }
    
    private func loadJSONFile(filename: String) throws -> MapDataJSON {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw MapDataError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(MapDataJSON.self, from: data)
        } catch {
            throw MapDataError.decodingError(error)
        }
    }
    
    private func processMapData(_ data: MapDataJSON) {
        // Update configuration
        configuration = MapConfiguration(
            scaleFactor: data.configuration.scaleFactor,
            nearPointTolerance: data.configuration.nearPointTolerance,
            linePointTolerance: data.configuration.linePointTolerance
        )
        
        // Process hallways
        hallways = data.pathSegments.map { segment in
            let scaledStart = scalePoint(segment.start.cgPoint)
            let scaledEnd = scalePoint(segment.end.cgPoint)
            return Hallway(start: scaledStart, end: scaledEnd)
        }
        
        // Process landmarks
        landmarks = data.landmarks.map { landmarkData in
            let scaledPosition = scalePoint(landmarkData.position.cgPoint)
            let entrancePoint = findNearestPathPoint(from: scaledPosition)
            
            return Landmark(
                name: landmarkData.name,
                labelPosition: scaledPosition,
                entrancePoint: entrancePoint
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func scalePoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x * configuration.scaleFactor,
            y: point.y * configuration.scaleFactor
        )
    }
    
    private func findNearestPathPoint(from point: CGPoint) -> CGPoint {
        var nearestPoint = point
        var minDistance = CGFloat.infinity
        
        for hallway in hallways {
            let candidatePoint = nearestPointOnLine(
                from: point,
                to: hallway.start,
                and: hallway.end
            )
            let distance = DistanceFormula(from: point, to: candidatePoint)
            
            if distance < minDistance {
                minDistance = distance
                nearestPoint = candidatePoint
            }
        }
        
        return nearestPoint
    }
    
    private func nearestPointOnLine(from point: CGPoint, to lineStart: CGPoint, and lineEnd: CGPoint) -> CGPoint {
        let lineVec = CGPoint(x: lineEnd.x - lineStart.x, y: lineEnd.y - lineStart.y)
        let pointVec = CGPoint(x: point.x - lineStart.x, y: point.y - lineStart.y)
        
        let lineLen = sqrt(lineVec.x * lineVec.x + lineVec.y * lineVec.y)
        
        // Handle zero-length line
        guard lineLen > 0 else { return lineStart }
        
        let lineUnitVec = CGPoint(x: lineVec.x / lineLen, y: lineVec.y / lineLen)
        let pointProjected = lineUnitVec.x * pointVec.x + lineUnitVec.y * pointVec.y
        let t = max(0.0, min(lineLen, pointProjected))
        
        return CGPoint(
            x: lineStart.x + lineUnitVec.x * t,
            y: lineStart.y + lineUnitVec.y * t
        )
    }
    
    // MARK: - Public Methods
    
    /// Reload map data from a different file
    func reloadFromFile(_ filename: String) {
        loadMapData(from: filename)
    }
    
    /// Get landmarks sorted alphabetically
    var sortedLandmarks: [Landmark] {
        landmarks.sorted { $0.name < $1.name }
    }
    
    /// Find a landmark by name
    func landmark(named name: String) -> Landmark? {
        landmarks.first { $0.name == name }
    }
    
    /// Check if a point is near any hallway
    func isPointOnPath(_ point: CGPoint) -> Bool {
        for hallway in hallways {
            if PointIsOnLine(
                lineStart: hallway.start,
                lineEnd: hallway.end,
                point: point,
                tolerance: configuration.linePointTolerance
            ) {
                return true
            }
        }
        return false
    }
}

// MARK: - Geometry Helper Extension

func PointIsOnLine(lineStart: CGPoint, lineEnd: CGPoint, point: CGPoint, tolerance: CGFloat) -> Bool {
    // Check if point is within the bounding box of the line segment
    let minX = min(lineStart.x, lineEnd.x) - tolerance
    let maxX = max(lineStart.x, lineEnd.x) + tolerance
    let minY = min(lineStart.y, lineEnd.y) - tolerance
    let maxY = max(lineStart.y, lineEnd.y) + tolerance
    
    if point.x < minX || point.x > maxX || point.y < minY || point.y > maxY {
        return false
    }
    
    // Check if the point is on the line using cross product
    let crossProduct = (point.y - lineStart.y) * (lineEnd.x - lineStart.x) - (point.x - lineStart.x) * (lineEnd.y - lineStart.y)
    
    return abs(crossProduct) < tolerance * DistanceFormula(from: lineStart, to: lineEnd)
}

// MARK: - Usage in Production

/*
 Usage Example:
 
 // In your ViewModel or View:
 let mapData = MapData.shared
 
 // Access data
 let allHallways = mapData.hallways
 let allLandmarks = mapData.landmarks
 
 // Get sorted landmarks for picker
 let sortedLandmarks = mapData.sortedLandmarks
 
 // Find specific landmark
 if let pantry = mapData.landmark(named: "Pantry") {
 // Use pantry landmark
 }
 
 // Reload with different map file
 mapData.reloadFromFile("alternative_map_data")
 
 // Check loading status
 if mapData.isLoaded {
 // Map loaded successfully
 } else if let error = mapData.loadError {
 // Handle error
 }
 */
