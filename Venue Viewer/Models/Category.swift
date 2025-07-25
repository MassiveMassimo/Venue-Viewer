//
//  Category.swift
//  Venue Viewer
//
//  Created by Reinhart on 25/07/25.
//

import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let selectedImageName: String
    let isBottomSheetModal: Bool = false
}
