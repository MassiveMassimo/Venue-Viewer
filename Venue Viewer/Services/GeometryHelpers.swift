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

// MARK: - Image Display and Coordinate Transformation

/// Represents the display properties of an image with scaledToFit mode
struct ImageDisplayFrame {
    /// The actual displayed size of the image within the container
    let displaySize: CGSize
    /// The frame of the displayed image within the container (includes position)
    let displayFrame: CGRect
    /// The scale factor applied to fit the image
    let scaleFactor: CGFloat
    /// The offset from the container's origin to the image's origin
    let offset: CGPoint
}

/// Calculates the display frame and properties for an image with scaledToFit mode
/// - Parameters:
///   - originalImageSize: The original size of the image (e.g., 1097×2415)
///   - containerSize: The size of the container view
/// - Returns: ImageDisplayFrame containing all display properties
func calculateImageDisplayFrame(originalImageSize: CGSize, containerSize: CGSize) -> ImageDisplayFrame {
    // Calculate scale factor to fit the image within the container
    let scaleX = containerSize.width / originalImageSize.width
    let scaleY = containerSize.height / originalImageSize.height
    let scaleFactor = min(scaleX, scaleY) // scaledToFit uses the smaller scale
    
    // Calculate the displayed size
    let displaySize = CGSize(
        width: originalImageSize.width * scaleFactor,
        height: originalImageSize.height * scaleFactor
    )
    
    // Calculate offset to center the image in the container
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
    
    return ImageDisplayFrame(
        displaySize: displaySize,
        displayFrame: displayFrame,
        scaleFactor: scaleFactor,
        offset: offset
    )
}

/// Transforms a point from original image coordinates to display coordinates
/// - Parameters:
///   - point: Point in original image coordinate space (e.g., within 1097×2415)
///   - imageDisplayFrame: The display frame properties of the image
/// - Returns: Point in the display coordinate space
func transformPointToDisplay(point: CGPoint, imageDisplayFrame: ImageDisplayFrame) -> CGPoint {
    return CGPoint(
        x: imageDisplayFrame.displayFrame.minX + point.x * imageDisplayFrame.scaleFactor,
        y: imageDisplayFrame.displayFrame.minY + point.y * imageDisplayFrame.scaleFactor
    )
}

/// Transforms a point from display coordinates back to original image coordinates
/// - Parameters:
///   - point: Point in display coordinate space
///   - imageDisplayFrame: The display frame properties of the image
/// - Returns: Point in the original image coordinate space
func transformPointFromDisplay(point: CGPoint, imageDisplayFrame: ImageDisplayFrame) -> CGPoint {
    return CGPoint(
        x: (point.x - imageDisplayFrame.displayFrame.minX) / imageDisplayFrame.scaleFactor,
        y: (point.y - imageDisplayFrame.displayFrame.minY) / imageDisplayFrame.scaleFactor
    )
}

/// Convenience function specifically for the map image (1097×2415)
/// - Parameters:
///   - point: Point in original map coordinate space
///   - containerSize: The size of the container view
/// - Returns: Point in the display coordinate space
func transformMapPointToDisplay(point: CGPoint, containerSize: CGSize) -> CGPoint {
    let mapSize = CGSize(width: 1097, height: 2415)
    let displayFrame = calculateImageDisplayFrame(originalImageSize: mapSize, containerSize: containerSize)
    return transformPointToDisplay(point: point, imageDisplayFrame: displayFrame)
}
