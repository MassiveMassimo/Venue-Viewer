//
//  BoothListViewModel.swift
//  Venue Viewer
//
//  Created by Reinhart on 25/07/25.
//

import Foundation
import SwiftUI
import Combine

class BoothListViewModel: ObservableObject {
    @Published var booths: [Booth] = []
    @Published var offsetY: CGFloat = UIScreen.main.bounds.height * 0.75
    @Published var dragOffset: CGFloat = 0

    init() {
        loadData()
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        let newOffset = offsetY + value.translation.height
        let screenHeight = UIScreen.main.bounds.height
        
        withAnimation {
            if newOffset < screenHeight * 0.4 {
                offsetY = 10
            } else if newOffset > screenHeight * 0.6 {
                offsetY = screenHeight * 0.6
            } else {
                offsetY = screenHeight * 0.4
            }
        }
    }
    
    func handleCancel(){
        withAnimation {
            offsetY = UIScreen.main.bounds.height * 0.75
        }
    }

    private func loadData() {
        booths = BoothDataService.loadBoothData()
    }
}

