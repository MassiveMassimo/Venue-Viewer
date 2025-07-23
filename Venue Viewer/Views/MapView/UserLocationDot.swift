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

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 15*scale, height: 15*scale)
            .position(
                x: userMapPosition.x + offset.width,
                y: userMapPosition.y + offset.height
            )
    }
}

#Preview {
    UserLocationDot(userMapPosition: CGPoint(x: 150, y: 350), scale: 1.0, offset: .zero)
}
