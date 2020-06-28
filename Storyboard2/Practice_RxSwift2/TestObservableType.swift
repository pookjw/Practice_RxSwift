//
//  TestObservableType.swift
//  Practice_RxSwift2
//
//  Created by pook on 6/27/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RxSwift

class TestObservableType<E>: ObserverType where E: CustomStringConvertible {
    let name: String
    init(name: String) {
        self.name = name
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next(let x):
            print("\(name): \(x)")
        case .completed:
            print("\(name): completed")
        case .error(let error):
            print("\(name): \(error.localizedDescription)")
        }
    }
}
