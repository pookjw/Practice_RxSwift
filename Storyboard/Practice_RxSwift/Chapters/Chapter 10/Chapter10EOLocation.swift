//
//  Chapter10EOLocation.swift
//  Practice_RxSwift
//
//  Created by pook on 4/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation
import CoreLocation

enum Chapter10GeometryType: Decodable {
    case position
    case point
    case polygon
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let typeString = try container.decode(String.self)
        switch typeString {
        case "Point": self = .point
        case "Position": self = .position
        case "Polygon": self = .polygon
        default: throw Chapter10EOError.invalidJSON("Unknown geometry type \(typeString)")
        }
    }
}

struct Chapter10EOLocation: Decodable {
    let type: Chapter10GeometryType
    let date: Date?
    let coordinates: Array<CLLocationCoordinate2D>
    
    private enum CodingKeys: String, CodingKey {
        case type, date, coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Chapter10GeometryType.self, forKey: .type)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        let coords = try container.decode([Double].self, forKey: .coordinates)
        
        guard (coords.count % 2) == 0 else {
            throw Chapter10EOError.invalidJSON("Invalid coordinates")
        }
        coordinates = stride(from: 0, to: coords.count, by: 2).map { index in
            CLLocationCoordinate2D(latitude: coords[index], longitude: coords[index + 1])
        }
    }
}
