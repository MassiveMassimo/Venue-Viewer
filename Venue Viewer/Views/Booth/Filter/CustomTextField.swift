//
//  CustomTextField.swift
//  FilterSearch
//
//  Created by Mirabella on 23/07/25.
//

import SwiftUI

struct CustomTextField : View {
    @Binding var searchText : String
    @FocusState var isSearchFocused
    var onSubmit : () -> Void = {}
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Search Brand", text: $searchText)
                .focused($isSearchFocused)
                .onSubmit {
                    onSubmit()
                }
            if (!searchText.isEmpty) {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

