//
//  BrandDetailCard.swift
//  Venue Viewer
//
//  Created by Mirabella on 27/07/25.
//

import SwiftUI

struct BrandDetailCard: View {
    let booth: Booth
    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(booth.boothName)
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("Peak hours")
                        .font(.caption)
                        .foregroundColor(Color.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }

                Text(booth.categories.first ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 12)

                Divider()
                HStack(spacing: 31) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.pink)
                        Text("300 m")
                    }

                    Rectangle()
                        .frame(width: 1, height: 20)
                        .foregroundColor(.gray.opacity(0.4))

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.pink)
                        Text("1 min")
                    }

                    Rectangle()
                        .frame(width: 1, height:20)
                        .foregroundColor(.gray.opacity(0.4))

                    Text("Hall \(booth.hall)")
                }
                .font(.subheadline)
                .padding(.top, 4)
                .padding(.bottom, 4)

                Divider()

                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.purple)
                    Text("Next Flash Sale in")
                    Text("00 : 30 : 10")
                        .fontWeight(.semibold)
            
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
                .padding(.top, 12)
                .padding(.bottom, 12)

                Button(action: {
      
                }) {
                    Text("Navigate")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.835, green: 0.169, blue: 0.31)) // #D52B4F
                        .cornerRadius(12)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding()
        }
    }

//#Preview {
//    BrandDetailCard()
//}
