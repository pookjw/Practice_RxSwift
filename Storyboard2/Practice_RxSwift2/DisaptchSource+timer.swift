//
//  DisaptchSource+timer.swift
//  Practice_RxSwift2
//
//  Created by pook on 6/27/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation

extension DispatchSource {
    public class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.setEventHandler(handler: handler)
        source.schedule(deadline: .now(), repeating: interval, leeway: .nanoseconds(0))
        source.resume()
        return source
    }
}
