//
//  BoothDataService.swift
//  Venue Viewer
//
//  Created by Reinhart on 25/07/25.
//

import Foundation

class BoothDataService {
    static func loadBoothData() -> [Booth] {
        guard let url = Bundle.main.url(forResource: "booth_data", withExtension: "json") else {
            print("Booth data file not found.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(DataResponse.self, from: data)
            return response.booths
        } catch {
            print("Failed to decode booth data: \(error)")
            return []
        }
    }
}
