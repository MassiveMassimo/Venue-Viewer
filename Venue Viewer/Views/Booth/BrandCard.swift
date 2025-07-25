//
//  BrandCard.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct BrandCard: View {
    let boothName: String
    let category: String
    let imageName: String
    var iconSize: CGFloat = 50
    var iconBackground: Color = Color.pink.opacity(0.2)

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: iconSize, height: iconSize)

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1)
                    )
            }

            HStack(spacing: 9) {
                Text(boothName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text("·")
                    .foregroundColor(.gray)
                
                Text(category)
                    .font(.body)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    BrandCard(boothName: "Brand Name", category: "Brand Category", imageName: "sample-image")
}
