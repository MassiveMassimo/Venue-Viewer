//
//  BrandOffers.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//
import SwiftUI

struct BrandOffers: View {
    let isBottomSheetModal: Bool
    @State private var selectedOptions: Set<String> = []
    @State private var selectedCategories: Set<String> = []

       
    
    var body: some View {
        VStack(alignment: isBottomSheetModal ? .center : .leading, spacing: 16){
            if(isBottomSheetModal) {
                Text("Brand Offers")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                Divider()
                    .padding(.top, 10)
               
            } else {
//                Divider()
//                    .padding(.bottom, 10)
                Text("Brand Offers")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
//                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 10) {
                ForEach(["Flash Sale", "Freebies", "Hands On Tester"], id: \.self) { option in
                    Button(action: {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }) {
                        Text(option)
                            .font(.caption)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 6)
                            .background(selectedOptions.contains(option) ? Color.pink : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            
                    }
                }
            }
     
//            .padding(.top, 20)
            .padding(.bottom, 10)
            
            if(isBottomSheetModal) {
                Divider()
                
                ActionButtons(
                    selectedOptions: $selectedOptions
                )
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
        }
//        .background(Color.red)
//        .cornerRadius(24)
    }
}


struct BrandOffers_Previews: PreviewProvider {
    static var previews: some View {
        BrandOffers(isBottomSheetModal:false)
    }
}
