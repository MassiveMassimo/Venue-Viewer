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
                .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            CategoriesSheetView(isBottomSheetModal: false)
                .padding(.bottom, 28)
                .padding(.leading, 8)
            Divider()
            BrandOffers(isBottomSheetModal: false)
                .padding(.leading, 28)
            Divider()
            BoothTraffic(isBottomSheetModal: false)
                .padding(.leading, 28)
            Divider()
            ActionButtons(
                selectedOptions: $selectedOptions
            )
        }
                .padding(.bottom, 30)     
                .background(Color.white)
    }
}

#Preview {
    FilterModalView()
}
