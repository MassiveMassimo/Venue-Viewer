//
//  BoothModel.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import Foundation

struct Coordinate: Decodable, Identifiable {
    let id = UUID()
    var long: Double
    var lat: Double
}

struct MapCoor: Decodable, Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
}

struct Booth: Decodable, Identifiable {
    let id: Int
    var boothName: String
    var boothNumber: String
    var hall: String
    var categories: [String]
    var flashSaleSchedule: [String]
    var crowdlevel: Int
    var coordinates: [Coordinate]
    var mapCoor: [MapCoor]

    private enum CodingKeys: String, CodingKey {
        case id, boothName, boothNumber, hall = "Hall", categories, flashSaleSchedule, crowdlevel, coordinates, mapCoor = "mapCoordinates"
    }
}
