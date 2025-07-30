//
//  UserLocationDot.swift
//  Venue Viewer
//
//  Created by Reinhart on 23/07/25.
//

import SwiftUI

struct UserLocationDot: View {
    let userMapPosition: CGPoint
    let scale: CGFloat
    let offset: CGSize
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 15*scale, height: 15*scale)
            .position(
                x: userMapPosition.x,
                y: userMapPosition.y
            )
    }
}

#Preview {
    UserLocationDot(userMapPosition: CGPoint(x: 150, y: 350), scale: 1.0, offset: .zero, color: Color.blue)
}
