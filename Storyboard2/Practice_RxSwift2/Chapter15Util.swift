//
//  Chapter15Util.swift
//  Practice_RxSwift2
//
//  Created by pook on 6/29/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RxSwift

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())

class Chapter15Util {
    static let shared = Chapter15Util()
    let start = Date()
    
    func getThreadName() -> String {
        if Thread.current.isMainThread {
            return "Main Thread \(Thread.current.name)"
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
        return String(format: "%02i", Int(Date().timeIntervalSince(Chapter15Util.shared.start).rounded()))
    }
}

extension ObservableType {
    func dump() -> RxSwift.Observable<Self.Element> {
        return self.do(onNext: { element in
            let threadName = Chapter15Util.shared.getThreadName()
            print("\(Chapter15Util.shared.secondsElapsed())s | [dump] \(element) received on \"\(threadName)\"")
        })
    }
    
    func dumpingSubscription() -> Disposable {
        return self.subscribe(onNext: { element in
            let threadName = Chapter15Util.shared.getThreadName()
            print("\(Chapter15Util.shared.secondsElapsed())s | [dumpingSubscription] \(element) received on \"\(threadName)\"")
        })
    }
}
