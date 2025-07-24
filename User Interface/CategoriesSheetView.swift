//
//  Categories.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct Category: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let selectedImageName: String
    let isBottomSheetModal: Bool = false
}

struct CategoriesSheetView: View {
    let isBottomSheetModal: Bool
    
    let allCategories: [Category] = [
        .init(name: "Skincare", imageName: "skincare", selectedImageName: "skincare-fill"),
        .init(name: "Make Up", imageName: "makeup", selectedImageName: "makeup-fill"),
        .init(name: "Body", imageName: "body", selectedImageName: "body-fill"),
        .init(name: "Hair", imageName: "hair", selectedImageName: "hair-fill"),
        .init(name: "Nails", imageName: "nail", selectedImageName: "nail-fill"),
        .init(name: "Fragrance", imageName: "fragrance", selectedImageName: "fragrance-fill"),
        .init(name: "Tools", imageName: "tools", selectedImageName: "tools-fill"),
        .init(name: "Men's care", imageName: "men", selectedImageName: "men-fill"),
        .init(name: "Beauty Suplement", imageName: "beauty", selectedImageName: "beauty-fill"),
        .init(name: "Salon & Clinic", imageName: "salon", selectedImageName: "salon-fill")
    ]
    
    @State private var selectedCategories: [Category] = []
    @State private var selectedOptions: Set<String> = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack{
         VStack(alignment: isBottomSheetModal ? .center : .leading, spacing: 16) {
                if isBottomSheetModal {
                    Text("Categories")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.top, 40)
                    Divider()
                        .padding(.top, 10)
                } else {
                        Text("Categories")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(allCategories) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category),
                            onTap: {
                                toggleCategory(category)
                                syncSelectedOptions()
                            }
                        )
                    }
                }
                .padding(.horizontal)
              
                if(isBottomSheetModal) {
                    Divider()
                    ActionButtons(
                        selectedOptions: $selectedOptions,
                        selectedCategories: $selectedCategories
                    )
                }
            }
//            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(24)
    }
    
    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
    
    private func syncSelectedOptions() {
        selectedOptions = Set(selectedCategories.map { $0.name })
    }
}

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


#Preview {
    CategoriesSheetView(isBottomSheetModal: false)
}
