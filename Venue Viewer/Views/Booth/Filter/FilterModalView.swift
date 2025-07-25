//
//  FilterModalView.swift
//  FilterSearch
//
//  Created by Mirabella on 22/07/25.
//

import SwiftUI

struct FilterModalView: View {
//    @State private var selectedOptions: Set<String> = []
    @Binding var brandOptions: Set<String>
    @Binding var boothTrafficOptions: Set<String>
    @Binding var categoriesOptions: Set<String>
    var body: some View {
        VStack(alignment: .center) {
            Text("Filters")
                .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            CategoriesSheetView(selectedOptions: $categoriesOptions, isBottomSheetModal: false)
                .padding(.bottom, 28)
                .padding(.leading, 8)
            Divider()
            BrandOffers(isBottomSheetModal: false, selectedOptions: $brandOptions)
                .padding(.leading, 28)
            Divider()
            BoothTraffic(selectedOptions: $boothTrafficOptions, isBottomSheetModal: false)
                .padding(.leading, 28)
            Divider()
            ActionButtons(
                brandOptions: $brandOptions,
                boothTrafficOptions: $boothTrafficOptions,
                categoriesOptions: $categoriesOptions
            )
        }
                .padding(.bottom, 30)     
                .background(Color.white)
    }
}

//#Preview {
//    FilterModalView()
//}
