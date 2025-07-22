import SwiftUI

// MARK: - Geometry Functions
func DistanceFormula(from: CGPoint, to: CGPoint) -> CGFloat {
    let squaredDistance = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    return sqrt(squaredDistance)
}

func isNearPoint(_ p1: CGPoint, _ p2: CGPoint) -> Bool {
    return abs(p1.x - p2.x) < 1 && abs(p1.y - p2.y) < 1
}

func PointIsOnLine(lineStart: CGPoint, lineEnd: CGPoint, point: CGPoint) -> Bool {
    let epsilon: CGFloat = 3.0 // Tolerance for floating point comparison
    
    // Check if point is within the bounding box of the line segment
    let minX = min(lineStart.x, lineEnd.x) - epsilon
    let maxX = max(lineStart.x, lineEnd.x) + epsilon
    let minY = min(lineStart.y, lineEnd.y) - epsilon
    let maxY = max(lineStart.y, lineEnd.y) + epsilon
    
    if point.x < minX || point.x > maxX || point.y < minY || point.y > maxY {
        return false
    }
    
    // Check if the point is on the line using cross product
    let crossProduct = (point.y - lineStart.y) * (lineEnd.x - lineStart.x) - (point.x - lineStart.x) * (lineEnd.y - lineStart.y)
    
    return abs(crossProduct) < epsilon * DistanceFormula(from: lineStart, to: lineEnd)
}

// MARK: - Conversion Functions
func numberToMeters(number: CGFloat) -> String {
    let metersConversionFactor = CGFloat(1) / CGFloat(10)
    let meters = number * metersConversionFactor
    return String(format: "%.1f", meters)
}

func numberToSeconds(number: CGFloat) -> String {
    let secondsConversionFactor = CGFloat(1) / CGFloat(14)
    let seconds = number * secondsConversionFactor
    return "\(Int(seconds))"
}
