import SwiftUI

class PathfindingService {
    func findShortestRoute(from start: CGPoint, to end: CGPoint) -> Route? {
        let vertices = buildVertexGraph(startingPoint: start, destinationPoint: end)
        return findShortestPath(vertices: vertices, start: start, end: end)
    }
    
    private func buildVertexGraph(startingPoint: CGPoint, destinationPoint: CGPoint) -> [Vertex] {
        var vertices = [Vertex]()
        var vertexCache: [CGPoint: Vertex] = [:] // Temporary cache for building
        
        func getOrCreateVertex(at point: CGPoint) -> Vertex {
            // Check cache first (exact match)
            if let cached = vertexCache[point] {
                return cached
            }
            
            // Check for nearby points
            for (existingPoint, existingVertex) in vertexCache {
                if isNearPoint(existingPoint, point) {
                    return existingVertex
                }
            }
            
            // Create new vertex
            let newVertex = Vertex(point: point)
            vertices.append(newVertex)
            vertexCache[point] = newVertex
            return newVertex
        }
        
        // Helper to connect two points
        func connectPoints(_ p1: CGPoint, _ p2: CGPoint) {
            let v1 = getOrCreateVertex(at: p1)
            let v2 = getOrCreateVertex(at: p2)
            v1.touchingHallways.append(Hallway(start: p1, end: p2))
            v2.touchingHallways.append(Hallway(start: p2, end: p1))
        }
        
        // Add all hallway endpoints
        for hallway in MapData.shared.hallways {
            connectPoints(hallway.start, hallway.end)
        }
        
        // Handle special points (starting and destination)
        for point in [startingPoint, destinationPoint] {
            for hallway in MapData.shared.hallways {
                if PointIsOnLine(lineStart: hallway.start, lineEnd: hallway.end, point: point) &&
                    !isNearPoint(point, hallway.start) && !isNearPoint(point, hallway.end) {
                    connectPoints(point, hallway.start)
                    connectPoints(point, hallway.end)
                }
            }
        }
        
        return vertices
    }
    
    private func findShortestPath(vertices: [Vertex], start: CGPoint, end: CGPoint) -> Route? {
        guard let startIndex = vertices.firstIndex(where: { isNearPoint($0.point, start) }),
              let endIndex = vertices.firstIndex(where: { isNearPoint($0.point, end) })
        else { return nil }
        
        let startVertex = vertices[startIndex]
        let endVertex = vertices[endIndex]
        
        // Reset all vertices
        vertices.forEach { vertex in
            vertex.visited = false
            vertex.distance = .infinity
            vertex.heuristic = DistanceFormula(from: vertex.point, to: endVertex.point)
            vertex.previousHallway = nil
        }
        
        // Use indices for tracking open set
        var openIndices = Set<Int>([startIndex])
        startVertex.distance = 0
        
        while !openIndices.isEmpty {
            // Find vertex with minimum fCost
            guard let currentIndex = openIndices.min(by: {
                vertices[$0].fCost < vertices[$1].fCost
            }) else { break }
            
            let current = vertices[currentIndex]
            
            // Check if we reached the destination
            if currentIndex == endIndex {
                // Build path by backtracking
                var path = [Vertex]()
                var currentVertex: Vertex? = current
                
                while let vertex = currentVertex {
                    path.insert(vertex, at: 0)
                    
                    // Find previous vertex
                    if let previousHallway = vertex.previousHallway {
                        currentVertex = vertices.first {
                            isNearPoint($0.point, previousHallway.start)
                        }
                    } else {
                        currentVertex = nil
                    }
                }
                
                return Route(distance: current.distance, path: path)
            }
            
            // Remove from open set and mark as visited
            openIndices.remove(currentIndex)
            current.visited = true
            
            // Process all neighbors
            for hallway in current.touchingHallways {
                // Find the neighbor vertex
                guard let neighborIndex = vertices.firstIndex(where: {
                    isNearPoint($0.point, hallway.end)
                }) else { continue }
                
                let neighbor = vertices[neighborIndex]
                
                // Skip if already visited
                if neighbor.visited { continue }
                
                // Calculate tentative distance
                let tentativeDistance = current.distance + hallway.length
                
                // Update if we found a shorter path
                if tentativeDistance < neighbor.distance {
                    neighbor.distance = tentativeDistance
                    neighbor.previousHallway = hallway
                    openIndices.insert(neighborIndex)
                }
            }
        }
        
        // No path found
        return nil
    }
}
