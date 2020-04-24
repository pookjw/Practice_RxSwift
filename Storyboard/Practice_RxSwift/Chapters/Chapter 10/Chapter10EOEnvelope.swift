//
//  Chapter10EOEnvelope.swift
//  Practice_RxSwift
//
//  Created by pook on 4/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation

extension CodingUserInfoKey {
    static let contentIdentifier = CodingUserInfoKey(rawValue: "contentIdentifier")!
}

struct Chapter10EOEnvelope<Content: Decodable>: Decodable {
    let content: Content
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? = nil
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        guard let ci = decoder.userInfo[CodingUserInfoKey.contentIdentifier],
        let conentIdentifier = ci as? String,
        let key = CodingKeys(stringValue: conentIdentifier) else {
            throw Chapter10EOError.invalidDecoderConfiguration
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(Content.self, forKey: key)
    }
}
