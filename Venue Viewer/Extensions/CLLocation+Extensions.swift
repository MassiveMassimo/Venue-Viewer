//
//  CLLocation+Extensions.swift
//  Venue Viewer
//
//  Created by Reinhart on 23/07/25.
//

import Foundation
import CoreLocation
import CoreGraphics

extension CLLocation {
    func toMapPoint(in frame: CGRect) -> CGPoint {
        let minLon = 106.65219
        let maxLon = 106.65248
        let minLat = -6.30221
        let maxLat = -6.30215

        let normX = (coordinate.longitude - minLon) / (maxLon - minLon)
        let normY = 1.0 - (coordinate.latitude - minLat) / (maxLat - minLat)

        return CGPoint(
            x: frame.origin.x + normX * frame.width,
            y: frame.origin.y + normY * frame.height
        )
    }
}
