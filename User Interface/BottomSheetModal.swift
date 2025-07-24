//
//  BottomSheetModal.swift
//  FilterSearch
//
//  Created by Mirabella on 17/07/25.
//
import SwiftUI

struct BottomSheetModal: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var isCategorySheetPresented = false
    @State private var recentSearches: [String] = []
    @State private var isBrandOffersPresented = false
    @State private var isBoothTrafficPresented = false
    @State private var isFilterPresented = false
    
    var allBooths: [Booth]
    let alphabet = (65...90).map { String(UnicodeScalar($0)!) }
    
    var filteredBooths: [Booth] {
        if searchText.isEmpty {
            return allBooths
        } else {
            return allBooths.filter { $0.boothName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var groupedBooths: [String: [Booth]] {
        Dictionary(grouping: filteredBooths) { booth in
            String(booth.boothName.prefix(1)).uppercased()
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    TextField("Search Brand", text: $searchText)
                        .focused($isSearchFocused)
                        .onSubmit {
                            if !searchText.isEmpty && !recentSearches.contains(searchText) {
                                recentSearches.insert(searchText, at: 0)
                                if recentSearches.count > 5 {
                                    recentSearches.removeLast()
                                }
                            }
                        }
                    if (!searchText.isEmpty) {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Button{}
                label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                        
                }
                .padding(.trailing)
                
                Spacer()
            }
            
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button {
                        isFilterPresented = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    ForEach(["Categories", "Brand Offers", "Booth Traffic"], id: \.self) { item in
                        HStack(spacing: 4) {
                            Text(item)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .onTapGesture {
                            if item == "Categories" {
                                isCategorySheetPresented = true
                            } else if item == "Brand Offers" {
                                isBrandOffersPresented = true
                            } else if item == "Booth Traffic" {
                                isBoothTrafficPresented = true
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if !recentSearches.isEmpty {
                VStack(spacing: 8) {
                    Divider()
                    HStack {
                        Text("Recent")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Button("Clear") {
                            recentSearches.removeAll()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(recentSearches.enumerated()), id: \.element) { index, term in
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text(term)
                                Spacer()
                                
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                searchText = term
                                isSearchFocused = true
                            }
                            
                          
                            if index != recentSearches.count - 1 {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    
                    Divider()
                }
            }
            
            Text("List of Brands")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(alphabet, id: \.self) { letter in
                        if let boothsForLetter = groupedBooths[letter], !boothsForLetter.isEmpty {
                            
                            Text(letter)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 1)
                                .padding(.leading, 15)
                            VStack(alignment: .leading, spacing: 0) {

                               
                                ForEach(boothsForLetter) { booth in
                                    BrandCard(
                                        boothName: booth.boothName,
                                        category: booth.categories.first ?? "",
                                        imageName: "sample-image"
                                    )
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)

                                    if booth.id != boothsForLetter.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 20)
        .background(Color.white)
        .cornerRadius(24)
        .sheet(isPresented: $isCategorySheetPresented) {
            CategoriesSheetView(isBottomSheetModal: true)
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $isBrandOffersPresented) {
            BrandOffers(isBottomSheetModal: true)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $isBoothTrafficPresented) {
            BoothTraffic(isBottomSheetModal: true)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterModalView()
                .presentationDetents([.fraction(1.0), .large  ])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }
}

#Preview {
    let sampleBooths = [
        Booth(id: 1, boothName: "Avory", boothNumber: "F01", hall: "1", categories: ["Skincare"], flashSaleSchedule: [], crowdlevel: 0, coordinates: [Coordinate(long: 106.801, lat: -6.101)], mapCoor: [MapCoor(x: 110, y: 305)]),
        Booth(id: 2, boothName: "Avoskin", boothNumber: "F02", hall: "1", categories: ["Skincare"], flashSaleSchedule: [], crowdlevel: 0, coordinates: [Coordinate(long: 106.802, lat: -6.102)], mapCoor: [MapCoor(x: 120, y: 310)])
    ]
    
    return BottomSheetModal(allBooths: sampleBooths)
}
