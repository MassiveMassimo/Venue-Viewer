//
//  FilterModalView.swift
//  FilterSearch
//
//  Created by Mirabella on 22/07/25.
//

import SwiftUI

struct FilterModalView: View {
    @State private var selectedOptions: Set<String> = []
    var body: some View {
        VStack(alignment: .center) {
            Text("Filters")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            CategoriesSheetView(isBottomSheetModal: false)
            BrandOffers(isBottomSheetModal: false)
            BoothTraffic(isBottomSheetModal: false)
            ActionButtons(
                selectedOptions: $selectedOptions
            )
        }
        Spacer()
    }
}

#Preview {
    FilterModalView()
}
