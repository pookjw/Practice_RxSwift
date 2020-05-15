//
//  Chapter15Utils.swift
//  Practice_RxSwift
//
//  Created by pook on 5/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation
import RxSwift

class Chapter15Utils {
    
    static let shared = Chapter15Utils()
    
    let start = Date()
    
    func getThreadName() -> String {
        if Thread.current.isMainThread {
            return "Main Thread"
        } else if let name = Thread.current.name {
            if name == "" {
                return "Annonymous Thread"
            }
            return name
        } else {
            return "Unknown Thread"
        }
    }
    
    func secondsElapsed() -> String {
        return String(format: "%02i", Int(Date().timeIntervalSince(Chapter15Utils.shared.start).rounded()))
    }
}

extension ObservableType {
    func dump() -> RxSwift.Observable<Self.Element> {
        return self.do(onNext: { element in
            let threadName = Chapter15Utils.shared.getThreadName()
            print("\(Chapter15Utils.shared.secondsElapsed())s | [D] \(element) received on \(threadName)")
        })
    }
    
    func dumpingSubscription() -> Disposable {
        return self.subscribe(onNext: { element in
            let threadName = Chapter15Utils.shared.getThreadName()
            print("\(Chapter15Utils.shared.secondsElapsed())s | [S] \(element) received on \(threadName)")
        })
    }
}
