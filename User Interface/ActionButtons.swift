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
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink.opacity(0.5))
                    .cornerRadius(12)
            }

            Button(action: {
                print("Apply with: \(selectedOptions)")
            }) {
                Text("Apply")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
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
