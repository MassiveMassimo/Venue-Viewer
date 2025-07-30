//
//  Categories.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import SwiftUI

struct CategoriesSheetView: View {
//    private var selectedCategories: [Category] = []
    private var selectedCategories: [Category] {
        allCategories.filter { selectedOptions.contains($0.name) }
    }
    
    @Binding var selectedOptions: Set<String>
    
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
//                            isSelected: selectedCategories.contains(category),
                            isSelected: selectedOptions.contains(category.name),
                            onTap: {
                                toggleCategory(category)
//                                syncSelectedOptions()
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                if(isBottomSheetModal) {
                    Divider()
                    ActionButtons(
                        brandOptions: nil,
                        boothTrafficOptions: nil,
                        categoriesOptions: $selectedOptions
                    )
                }
            }
            //            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(24)
//        .onAppear() {
//            selectedCategories = allCategories.filter { selectedOptions.contains($0.name) }
//        }
//        .onChange(of: selectedOptions) {
//            newValue in
//                selectedCategories.removeAll { category in
//                    !newValue.contains(category.name)
//                }
//        }
    }
    
    private func toggleCategory(_ category: Category) {
        if selectedOptions.contains(category.name) {
            selectedOptions.remove(category.name)
        } else {
            selectedOptions.insert(category.name)
        }
    }

//    private func syncSelectedOptions() {
//        selectedOptions = Set(selectedCategories.map { $0.name })
//    }
}

//#Preview {
//    CategoriesSheetView(isBottomSheetModal: false)
//}
