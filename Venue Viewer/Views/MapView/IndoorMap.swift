//
//  IndoorMap.swift
//  Venue Viewer
//
//  Created by Reinhart on 23/07/25.
//

import SwiftUI
import CoreLocation

struct IndoorMap: View {
    let locationManager: LocationManager
    
    @State var scale: CGFloat = 1.0
    @State var offset: CGSize = .zero
    @State private var imgLoc: CGRect = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var gestureAnchor: CGPoint?
    
    var body: some View {
        GeometryReader { geo in
            let image = Image("gop_map")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(
                    GeometryReader { proxy in Color.clear.onAppear {
                        imgLoc = proxy.frame(in: .named("mapContainer"))
                    }}
                )
            
            ZStack {
                Color.clear
                
                image
                
                if let location = locationManager.currentLocation {
                    let mapPoint = location.toMapPoint(in: imgLoc)
                    
//                    Text("mapLoc: \(mapPoint.x), \(mapPoint.y) \n scale: \(scale)")
//                        .frame(maxHeight: .infinity, alignment: .topLeading)
                    UserLocationDot(userMapPosition: mapPoint, scale: 1/scale, offset: offset, color: Color.blue)
                    let otherUsers = locationManager.presenceUsers
                    if !otherUsers.isEmpty {
                        ForEach(otherUsers) { user in
                            let userMapPoint = user.location.toMapPoint(in: imgLoc)
                            UserLocationDot(userMapPosition: userMapPoint, scale: 1/scale, offset: offset, color: Color.green)
                        }
                    }
                }else {
                    Text("Location not found").frame(maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            if let anchor = gestureAnchor {
                                let newScale = lastScale * value
                                let deltaScale = newScale / scale
                                
                                let anchorInView = CGPoint(
                                    x: anchor.x - geo.size.width / 2,
                                    y: anchor.y - geo.size.height / 2
                                )
                                
                                offset = CGSize(
                                    width: offset.width - anchorInView.x * (deltaScale - 1),
                                    height: offset.height - anchorInView.y * (deltaScale - 1)
                                )
                                
                                scale = newScale
                            }
                        }
                        .onEnded { _ in
                            lastScale = scale
                            lastOffset = offset
                            gestureAnchor = nil
                        }
                        .simultaneously(with: DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if gestureAnchor == nil {
                                    gestureAnchor = value.location
                                }
                            }
                        ),
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
        }
        .coordinateSpace(name: "mapContainer")
    }
}


//#Preview {
//    IndoorMap(scale: 1.0, offset: .zero)
//}
