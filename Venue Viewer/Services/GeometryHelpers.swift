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

// MARK: - Coordinate System Display and Transformation

/// Represents the display properties of a coordinate system displayed with scaledToFit mode
struct CoordinateDisplayFrame {
    /// The actual displayed size of the coordinate system within the container
    let displaySize: CGSize
    /// The frame of the displayed coordinate system within the container (includes position)
    let displayFrame: CGRect
    /// The scale factor applied to fit the coordinate system
    let scaleFactor: CGFloat
    /// The offset from the container's origin to the coordinate system's origin
    let offset: CGPoint
}

/// Calculates the display frame and properties for a coordinate system with scaledToFit mode
/// - Parameters:
///   - originalSize: The original size of the coordinate system bounds
///   - containerSize: The size of the container view
/// - Returns: CoordinateDisplayFrame containing all display properties
func calculateCoordinateDisplayFrame(originalSize: CGSize, containerSize: CGSize) -> CoordinateDisplayFrame {
    // Calculate scale factor to fit the coordinate system within the container
    let scaleX = containerSize.width / originalSize.width
    let scaleY = containerSize.height / originalSize.height
    let scaleFactor = min(scaleX, scaleY) // scaledToFit uses the smaller scale
    
    // Calculate the displayed size
    let displaySize = CGSize(
        width: originalSize.width * scaleFactor,
        height: originalSize.height * scaleFactor
    )
    
    // Calculate offset to center the coordinate system in the container
    let offset = CGPoint(
        x: (containerSize.width - displaySize.width) / 2,
        y: (containerSize.height - displaySize.height) / 2
    )
    
    // Create the display frame
    let displayFrame = CGRect(
        x: offset.x,
        y: offset.y,
        width: displaySize.width,
        height: displaySize.height
    )
    
    return CoordinateDisplayFrame(
        displaySize: displaySize,
        displayFrame: displayFrame,
        scaleFactor: scaleFactor,
        offset: offset
    )
}

/// Transforms a point from original coordinate space to display coordinates
/// - Parameters:
///   - point: Point in original coordinate space
///   - coordinateDisplayFrame: The display frame properties of the coordinate system
/// - Returns: Point in the display coordinate space
func transformPointToDisplay(point: CGPoint, coordinateDisplayFrame: CoordinateDisplayFrame) -> CGPoint {
    return CGPoint(
        x: coordinateDisplayFrame.displayFrame.minX + point.x * coordinateDisplayFrame.scaleFactor,
        y: coordinateDisplayFrame.displayFrame.minY + point.y * coordinateDisplayFrame.scaleFactor
    )
}

/// Transforms a point from display coordinates back to original coordinate space
/// - Parameters:
///   - point: Point in display coordinate space
///   - coordinateDisplayFrame: The display frame properties of the coordinate system
/// - Returns: Point in the original coordinate space
func transformPointFromDisplay(point: CGPoint, coordinateDisplayFrame: CoordinateDisplayFrame) -> CGPoint {
    return CGPoint(
        x: (point.x - coordinateDisplayFrame.displayFrame.minX) / coordinateDisplayFrame.scaleFactor,
        y: (point.y - coordinateDisplayFrame.displayFrame.minY) / coordinateDisplayFrame.scaleFactor
    )
}

/// Transforms a point from original coordinate space to display coordinates
/// - Parameters:
///   - point: Point in original coordinate space
///   - originalSize: The original size of the coordinate system
///   - containerSize: The size of the container view
/// - Returns: Point in the display coordinate space
func transformPointToDisplay(point: CGPoint, originalSize: CGSize, containerSize: CGSize) -> CGPoint {
    let displayFrame = calculateCoordinateDisplayFrame(originalSize: originalSize, containerSize: containerSize)
    return transformPointToDisplay(point: point, coordinateDisplayFrame: displayFrame)
}

// MARK: - Backward Compatibility Aliases

/// Legacy alias for CoordinateDisplayFrame - use CoordinateDisplayFrame instead
typealias ImageDisplayFrame = CoordinateDisplayFrame

/// Legacy function - use calculateCoordinateDisplayFrame instead
func calculateImageDisplayFrame(originalImageSize: CGSize, containerSize: CGSize) -> ImageDisplayFrame {
    return calculateCoordinateDisplayFrame(originalSize: originalImageSize, containerSize: containerSize)
}

/// Legacy function with imageDisplayFrame parameter - use coordinateDisplayFrame version instead
func transformPointToDisplay(point: CGPoint, imageDisplayFrame: ImageDisplayFrame) -> CGPoint {
    return transformPointToDisplay(point: point, coordinateDisplayFrame: imageDisplayFrame)
}

/// Legacy function with imageDisplayFrame parameter - use coordinateDisplayFrame version instead
func transformPointFromDisplay(point: CGPoint, imageDisplayFrame: ImageDisplayFrame) -> CGPoint {
    return transformPointFromDisplay(point: point, coordinateDisplayFrame: imageDisplayFrame)
}

/// Legacy function - use transformPointToDisplay(point:originalSize:containerSize:) instead
func transformMapPointToDisplay(point: CGPoint, originalImageSize: CGSize, containerSize: CGSize) -> CGPoint {
    return transformPointToDisplay(point: point, originalSize: originalImageSize, containerSize: containerSize)
}
