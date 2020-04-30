//
//  DispatchSource.swift
//  Practice_RxSwift
//
//  Created by pook on 4/25/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation

public extension DispatchSource {
    class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.setEventHandler(handler: handler)
        source.schedule(deadline: .now(), repeating: interval, leeway: .nanoseconds(0))
        source.resume()
        return source
    }
}
