//
//  CategoryCard.swift
//  Venue Viewer
//
//  Created by Reinhart on 25/07/25.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                Image(isSelected ? category.selectedImageName : category.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(category.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.7)
                    .padding(.bottom, 6)
                    .foregroundColor(.primary)
            }
            .frame(width: 72, height: 72)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.pink.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.pink : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

