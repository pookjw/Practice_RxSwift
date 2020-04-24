//
//  Chapter10EOEvent.swift
//  Practice_RxSwift
//
//  Created by pook on 4/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation

struct Chapter10EOEventCategory: Decodable {
    let id: Int
    let title: String
}

struct Chapter10EOEvent: Decodable {
    let id: String
    let title: String
    let description: String
    let link: URL?
    let closeDate: Date?
    let categories: [Chapter10EOEventCategory]
    let locations: [Chapter10EOLocation]?
    var date: Date? {
        return closeDate ?? locations?.compactMap {$0.date}.first
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, link, closeDate = "closed", categories, locations = "geometries"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        link = try container.decode(URL?.self, forKey: .link)
        closeDate = try container.decode(Date.self, forKey: .closeDate)
        categories = try container.decode([Chapter10EOEventCategory].self, forKey: .categories)
        // This may throw because we don't fully implement the GeoJSON spec. Let's igore those errors for now.
        locations = try? container.decode([Chapter10EOLocation].self, forKey: .locations)
    }
    
    static func compareDates(lhs: Chapter10EOEvent, rhs: Chapter10EOEvent) -> Bool {
        switch (lhs.date, rhs.date) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return true
        case (let ldate, let rdate): return ldate! < rdate!
        }
    }
}
