//
//  BoothTraffic.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct BoothTraffic: View {
    @State private var selectedOptions: Set<String> = []
    let isBottomSheetModal: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if(isBottomSheetModal){
                Text("Booth Traffics")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                Divider()
                    .padding(.top, 10)
            } else {
                Divider()
                    .padding(.bottom, 10)
                Text("Booth Traffics")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    if selectedOptions.contains("High Crowd") {
                        selectedOptions.remove("High Crowd")
                    } else {
                        selectedOptions.insert("High Crowd")
                    }
                }) {
                    Text("High Crowd")
                        .padding(10)
                        .background(selectedOptions.contains("High Crowd") ? Color.pink : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    if selectedOptions.contains("Medium Crowd") {
                        selectedOptions.remove("Medium Crowd")
                    } else {
                        selectedOptions.insert("Medium Crowd")
                    }
                }) {
                    Text("Medium Crowd")
                        .padding(10)
                        .background(selectedOptions.contains("Medium Crowd") ? Color.pink : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    if selectedOptions.contains("Low Crowd") {
                        selectedOptions.remove("Low Crowd")
                    } else {
                        selectedOptions.insert("Low Crowd")
                    }
                }) {
                    Text("Low Crowd")
                        .padding(10)
                        .background(selectedOptions.contains("Low Crowd") ? Color.pink : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, -10)
            .padding(.vertical, 20)
            
            if(isBottomSheetModal) {
                Divider()
                    .padding(.vertical, 10)
                
                ActionButtons(
                    selectedOptions: $selectedOptions
                )
                .padding(.horizontal)
                .padding(.top, 20)
                
            }
        }
    }
}

struct BoothTrafficPreviews: PreviewProvider {
    static var previews: some View {
        BoothTraffic(isBottomSheetModal: false)
    }
}
