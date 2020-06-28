//
//  Chapter11TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/25/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Chapter11TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter11TableViewCell", for: indexPath) as! Chapter11TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("replay & connect", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("buffer", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("buffer (2)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("window", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("delaySubscription", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("delay", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
        case 7:
            cell.actionButton.setTitle("interval", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
        case 8:
            cell.actionButton.setTitle("timer", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action9(_:)), for: .touchUpInside)
        case 9:
            cell.actionButton.setTitle("timeout", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action10(_:)), for: .touchUpInside)
        case 10:
            cell.actionButton.setTitle("timeout (2)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action11(_:)), for: .touchUpInside)
        default:
            ()
        }
        
        return cell
    }
    
    // MARK: Private Methods
    @objc private func action1(_ sender: UIButton) {
        print("Test Action Activated")
    }
    
    @objc private func action2(_ sender: UIButton) {
        let elementsPerSecond = 1
        let maxElements = 5
        let replayedElements = 1
        let replayDelay: TimeInterval = 3.0
        
        let sourceObservable = Observable<Int>.create { observer in
            var value = 1
            
            let timer = DispatchSource.timer(interval: 1.0, queue: .main) {
                print(value)
                if value <= maxElements {
                    observer.onNext(value)
                    value += 1
                }
            }
            
            return Disposables.create {
                timer.suspend()
            }
        }
        .replay(replayedElements)
        //.replayAll()
        
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emit \(elementsPerSecond) per second:"),
            UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:")
        ]
        let tlv: [TimelineViewBase] = [sourceTimeline, replayedTimeline]
        
        navigateToActionVC(stack: stack, tlv: tlv,title: "replay & connect")
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        }

        _ = sourceObservable.connect()
        // To see what the .connect() it is, remove sourceTimeline and replayedTimeline and comment .connect() code.
        
        // on View, you can see 3 and 4 get both, because of .replay(Int). Change that Int value to understand it!
    }
    
    @objc private func action3(_ sender: UIButton) {
        let bufferTimeSpan: RxTimeInterval = RxTimeInterval.milliseconds(4000)
        let bufferMaxCount = 2
        
        let sourceObservable = PublishSubject<String>()
        
        let sourceTimeline = TimelineView<String>.make()
        let bufferedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements:"),
            UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan)):")
        ]
        let tlv: [TimelineViewBase] = [
            sourceTimeline,
            bufferedTimeline
        ]
        
        navigateToActionVC(stack: stack, tlv: tlv, title: "buffer")
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        sourceObservable
            .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
            .map {
                //print(type(of: $0)) // Array<String>
                return $0.count
        }
        .subscribe(bufferedTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
        }
    }
    
    @objc private func action4(_ sender: UIButton) {
        let bufferTimeSpan: RxTimeInterval = RxTimeInterval.milliseconds(4000)
        let bufferMaxCount = 2
        
        let sourceObservable = PublishSubject<String>()
        
        let sourceTimeline = TimelineView<String>.make()
        let bufferedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements:"),
            UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan)):")
        ]
        let tlv: [TimelineViewBase] = [
            sourceTimeline,
            bufferedTimeline
        ]
        
        navigateToActionVC(stack: stack, tlv: tlv, title: "buffer (2)")
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        sourceObservable
            .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
            .map {
                //print(type(of: $0)) // Array<String>
                return $0.count
        }
        .subscribe(bufferedTimeline)
        
        _ = Observable<Void>.create { _ in
            let elementsPerSecond = 0.7
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                sourceObservable.onNext("🐱")
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .subscribe()
    }
    
    @objc private func action5(_ sender: UIButton) {
        let elementsPerSecond = 3
        let windowTimeSpan: RxTimeInterval = RxTimeInterval.milliseconds(4000)
        let windowMaxCount = 10
        
        let sourceObservable = PublishSubject<String>()
        
        let sourceTimeline = TimelineView<String>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements (\(elementsPerSecond) per sec.): "),
            UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")
        ]
        var tlv: [TimelineViewBase] = [
            sourceTimeline
        ]
        
        let avc = navigateToActionVC(stack: stack, tlv: tlv, title: "window")
        
        _ = Observable<Void>.create { _ in
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                sourceObservable.onNext("🐱")
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .subscribe()
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        _ = sourceObservable
            .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
            .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
                //print(type(of: windowedObservable)) // AddRef<String>
                let timeline = TimelineView<Int>.make()
                if avc.presentView != nil {
                    avc.presentView.addArrangedSubview(timeline)
                    //avc.presentView.keep(atMost: 8)
                }
                
                return windowedObservable
                    .map {value in (timeline, value)}
                    .concat(Observable.just((timeline, nil))) // concat with PublishSubject and Observable... if PS completed, Obs will run.
                //.concat(Observable.just((timeline, String?("C"))))
        }
        .subscribe(onNext: { tuple in
            let (timeline, value) = tuple
            if let value = value {
                timeline.add(.next(value))
            } else {
                print("completed")
                timeline.add(.completed(true))
            }
        })
    }
    
    @objc private func action6(_ sender: UIButton) {
        let elementsPerSecond = 1
        let delayInSeconds: RxTimeInterval = RxTimeInterval.milliseconds(1500)
        
        let sourceObservable = PublishSubject<Int>()
        
        let sourceTimeline = TimelineView<Int>.make()
        let delayedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
            UILabel.make("Delayed elements (with a \(delayInSeconds) delay):")
        ]
        let tlv: [TimelineViewBase] = [
            sourceTimeline,
            delayedTimeline
        ]
        
        navigateToActionVC(stack: stack, tlv: tlv, title: "delaySubscription")
        
        var current = 1
        _ = Observable<Void>.create { _ in
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                sourceObservable.onNext(current)
                current += 1
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .subscribe()
        
        _ = sourceObservable.subscribe(sourceTimeline)
        _ = sourceObservable.delaySubscription(delayInSeconds, scheduler: MainScheduler.instance)
            .subscribe(delayedTimeline)
    }
    
    @objc private func action7(_ sender: UIButton) {
        let elementsPerSecond = 1
        let delayInSeconds: RxTimeInterval = RxTimeInterval.milliseconds(1500)
        
        let sourceObservable = PublishSubject<Int>()
        
        let sourceTimeline = TimelineView<Int>.make()
        let delayedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
            UILabel.make("Delayed elements (with a \(delayInSeconds) delay):")
        ]
        let tlv: [TimelineViewBase] = [
            sourceTimeline,
            delayedTimeline
        ]
        
        navigateToActionVC(stack: stack, tlv: tlv, title: "delay")
        
        var current = 1
        _ = Observable<Void>.create { _ in
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                sourceObservable.onNext(current)
                current += 1
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .subscribe()
        
        _ = sourceObservable.subscribe(sourceTimeline)
        _ = sourceObservable
            .delay(delayInSeconds, scheduler: MainScheduler.instance)
            .subscribe(delayedTimeline)
    }
    
    @objc private func action8(_ sender: UIButton) {
        let elementsPerSecond = 1
        let maxElements = 5
        let replayedElements = 1
        let replayDelay: TimeInterval = 3.0
        
        let sourceObservable = Observable<Int>
            .interval(RxTimeInterval.microseconds(1000/elementsPerSecond*1000), scheduler: MainScheduler.instance)
            .replay(replayedElements)
        
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emit \(elementsPerSecond) per second:"),
            UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:")
        ]
        let tlv: [TimelineViewBase] = [sourceTimeline, replayedTimeline]
        
        navigateToActionVC(stack: stack, tlv: tlv,title: "interval")
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        }
        
        _ = sourceObservable.connect()
    }
    
    @objc private func action9(_ sender: UIButton) {
        let elementsPerSecond = 1
        let delayInSeconds: RxTimeInterval = RxTimeInterval.milliseconds(1500)
        
        let sourceObservable = PublishSubject<Int>()
        
        let sourceTimeline = TimelineView<Int>.make()
        let delayedTimeline = TimelineView<Int>.make()
        
        let stack: [UILabel] = [
            UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
            UILabel.make("Delayed elements (with a \(delayInSeconds) delay):")
        ]
        let tlv: [TimelineViewBase] = [
            sourceTimeline,
            delayedTimeline
        ]
        
        navigateToActionVC(stack: stack, tlv: tlv, title: "timer")
        
        var current = 1
        _ = Observable<Void>.create { _ in
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                sourceObservable.onNext(current)
                current += 1
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        .subscribe()
        
        _ = sourceObservable.subscribe(sourceTimeline)
        _ = Observable<Int>
            .timer(3, scheduler: MainScheduler.instance)
            .flatMap { _ -> Observable<Int> in
                print("Timer Done!")
                return sourceObservable.delay(delayInSeconds, scheduler: MainScheduler.instance)
        }
        .subscribe(delayedTimeline)
    }
    
    @objc private func action10(_ sender: UIButton) {
        let tapsTimeLine = TimelineView<String>.make()
        navigateToActionVC(stack: [], tlv: [tapsTimeLine], title: "timeout")
        
        let _ = sender
            .rx.tap
            .map { _ in "*" }
            .timeout(5, scheduler: MainScheduler.instance)
            .subscribe(tapsTimeLine)
    }
    
    @objc private func action11(_ sender: UIButton) {
        let tapsTimeLine = TimelineView<String>.make()
        navigateToActionVC(stack: [], tlv: [tapsTimeLine], title: "timeout (2)")
        
        let _ = sender
            .rx.tap
            .map { _ in "*" }
            .timeout(5, other: Observable.just("!"), scheduler: MainScheduler.instance)
            .subscribe(tapsTimeLine)
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
    
    @discardableResult
    private func navigateToActionVC(stack: [UILabel], tlv: [TimelineViewBase], title: String = "View") -> Chapter11ActionViewController {
        let actionController = storyboard!.instantiateViewController(withIdentifier: "Chapter11ActionViewController") as! Chapter11ActionViewController
        actionController.viewTitle = title
        actionController.stack = stack
        actionController.tlv = tlv
        navigationController!.pushViewController(actionController, animated: true)
        return actionController
    }
}

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        view.setup()
        return view
    }
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.next(String(describing: value)))
        case .completed:
            add(.completed())
        case .error(_):
            add(.error())
        }
    }
}
