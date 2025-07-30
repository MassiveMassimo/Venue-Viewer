//
//  BoothModel.swift
//  FilterSearch
//
//  Created by Mirabella on 21/07/25.
//

import Foundation

//struct Coordinate: Decodable, Identifiable {
//    let id = UUID()
//    var long: Double
//    var lat: Double
//}

struct MapCoor: Decodable {
//    let id = UUID()
    var x: Double
    var y: Double
}

struct Booth: Decodable, Identifiable {
    let id: Int
    var boothName: String
    var boothNumber: String
    var hall: String
    var categories: [String]
    var flashSaleSchedule: [CustomDateInterval]?
    var freebies: Bool
    var tester: Bool
    var locName: String
    var crowdlevel: Int
//    var coordinates: [Coordinate]
    var mapCoordinates: [MapCoor]

//    private enum CodingKeys: String, CodingKey {
//        case id, boothName, boothNumber, hall, categories, flashSaleSchedule, crowdlevel, coordinates, mapCoordinates
//    }
}

struct DataResponse: Decodable {
    let booths: [Booth]
}


struct CustomDateInterval: Decodable {
    let interval: DateInterval

    private enum CodingKeys: String, CodingKey {
        case start, end
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(Date.self, forKey: .start)
        let end = try container.decode(Date.self, forKey: .end)
        self.interval = DateInterval(start: start, end: end)
    }
}
