//
//  Chapter8Event.swift
//  Practice_RxSwift
//
//  Created by pook on 4/7/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation

struct Chapter8Event: Codable {
    let action: String
    let repo: Repo
    let actor: Actor
    
    enum CodingKeys: String, CodingKey {
        case action = "type"
        case repo
        case actor
    }
}

struct Repo: Codable {
    let name: String
}

struct Actor: Codable {
    let name: String
    let avatar: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "display_login"
        case avatar = "avatar_url"
    }
}
