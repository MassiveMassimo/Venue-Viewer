//
//  ContentView.swift
//  FilterSearch
//
//  Created by Mirabella on 17/07/25.
//

import SwiftUI

struct MainView: View {
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height * 0.75
    @GestureState private var dragOffset: CGFloat = 0
    @State private var allBooths: [Booth] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGray6).ignoresSafeArea()

            BottomSheetModal(allBooths: allBooths)
                .offset(y: max(0, offsetY + dragOffset))
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let newOffset = offsetY + value.translation.height
                            let screenHeight = UIScreen.main.bounds.height

                            withAnimation {
                                if newOffset < screenHeight * 0.4 {
                                    offsetY = 10
                                } else if newOffset > screenHeight * 0.6 {
                                    offsetY = screenHeight * 0.6 //
                                } else {
                                    offsetY = screenHeight * 0.4 // 
                                }
                            }
                        }
                )
                .animation(.easeInOut, value: dragOffset)
        }
        .onAppear(perform: loadData)
    }
    
    private func loadData() {
        if let url = Bundle.main.url(forResource: "Data", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(DataResponse.self, from: data)
                self.allBooths = response.booths
            } catch {
                print("Error loading data: \(error)")
            }
        }
    }
}

struct DataResponse: Decodable {
    let booths: [Booth]
}

#Preview {
    MainView()
}
