//
//  ActionButton.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct ActionButtons: View {
    @Binding var selectedOptions: Set<String>
    var selectedCategories: Binding<[Category]>? = nil  // optional
    

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                selectedOptions.removeAll()
                selectedCategories?.wrappedValue.removeAll()  // hanya jika tersedia
            }) {
                Text("Clear All")
                    .foregroundColor(Color(.primary))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.black, lineWidth: 1))
            }

            Button(action: {
                print("Apply with: \(selectedOptions)")
            }) {
                Text("Apply")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.primary))
                    .foregroundColor(.white)
                    .cornerRadius(7)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}


struct ActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        ActionButtons(
            selectedOptions: .constant([]),
            selectedCategories: .constant([])
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
