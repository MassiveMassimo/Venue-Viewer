//
//  ContentView.swift
//  FilterSearch
//
//  Created by Mirabella on 17/07/25.
//

import SwiftUI

struct BoothListView: View {
    @Binding var selectedDest: Landmark
    let landmarks: [Landmark]
    
    @GestureState private var dragOffset: CGFloat = 0
    @StateObject private var viewModel = BoothListViewModel()
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
//            Color(.systemGray6).ignoresSafeArea()

            BottomSheetModal(isExpanded: $isExpanded, selectedDest: $selectedDest, landmarks: landmarks, allBooths: viewModel.booths)
                .offset(y: max(0, viewModel.offsetY + dragOffset))
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            viewModel.handleDragEnded(value)
                            isExpanded = true
                        }
                )
                .animation(.easeInOut, value: dragOffset)
        }
        .onChange(of: isExpanded) {
            if !isExpanded {
                viewModel.handleCancel()
            }
        }
    }
}

//#Preview {
//    BoothListView()
//}
