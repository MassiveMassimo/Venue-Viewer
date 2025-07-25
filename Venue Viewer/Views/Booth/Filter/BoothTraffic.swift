//
//  BoothTraffic.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct BoothTraffic: View {
    @Binding var selectedOptions: Set<String>
    let isBottomSheetModal: Bool
    
    var body: some View {
        VStack(alignment: isBottomSheetModal ? .center : .leading, spacing: 0) {
            if(isBottomSheetModal){
                Text("Booth Traffics")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                Divider()
//                    .padding(.top, 10)
            } else {
//                Divider()
//                    .padding(.bottom, 10)
                Text("Booth Traffics")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
//                    .padding(.horizontal)
//                    .padding(.leading, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            HStack(spacing: 10) {
                ForEach(["High Crowd", "Medium Crowd", "Low Crowd"], id: \.self) { option in
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
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            if(isBottomSheetModal) {
                Divider()
                    .padding(.vertical, 10)
                
                ActionButtons(
                    brandOptions: nil,
                    boothTrafficOptions: nil,
                    categoriesOptions: $selectedOptions
                )
//                .padding(.horizontal)
//                .padding(.top, 20)
                
            }
        }
    }
}

//struct BoothTrafficPreviews: PreviewProvider {
//    static var previews: some View {
//        BoothTraffic(isBottomSheetModal: false)
//    }
//}
