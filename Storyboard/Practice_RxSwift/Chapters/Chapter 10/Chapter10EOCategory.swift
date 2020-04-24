//
//  Chapter10EOCategory.swift
//  Practice_RxSwift
//
//  Created by pook on 4/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation

struct Chapter10EOCategory: Decodable {
    let id: Int
    let name: String
    let description: String
    
    
    var events = [Chapter10EOEvent]()
    var endpoint: String {
        return "\(Chapter10EONET.categoriesEndpoint)/\(self.id)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name = "title", description
    }
}

extension Chapter10EOCategory: Equatable {
    static func ==(lhs: Chapter10EOCategory, rhs: Chapter10EOCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
