//
//  Chapter9TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/8/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift

class Chapter9TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter9TableViewCell", for: indexPath) as! Chapter9TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("startWith", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("concat", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("concatMap", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("merge", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("combineLatest", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("zip", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
        case 7:
            cell.actionButton.setTitle("withLatestFrom", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
        case 8:
            cell.actionButton.setTitle("amb (aka. ambiguous)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action9(_:)), for: .touchUpInside)
        case 9:
            cell.actionButton.setTitle("switchLatest", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action10(_:)), for: .touchUpInside)
        case 10:
            cell.actionButton.setTitle("reduce", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action11(_:)), for: .touchUpInside)
        case 11:
            cell.actionButton.setTitle("scan", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action12(_:)), for: .touchUpInside)
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
        let numbers = Observable<Int>.of(2, 3, 4)
        
        let observable = numbers.startWith(1)
        _ = observable.subscribe(onNext: { value in
            print(value)
        })
        // 1 2 3 4
    }
    
    @objc private func action3(_ sender: UIButton) {
        // concat with Int...
        let first = Observable.of(1, 2, 3)
        let second = Observable.of(4, 5, 6)
        
        let observable = Observable.concat([first, second])
        
        observable.subscribe(onNext: {print($0)})
        // 1 2 3 4 5 6
        
        // concat with String...
        let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
        let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
        
        let observable2 = germanCities.concat(spanishCities)
        print(type(of: observable2))
        observable2.subscribe(onNext: {print($0)})
        //Berlin Münich Frankfurt Madrid Barcelona Valencia
        
        let test1 = Observable.just(1)
        let test2 = Observable.just(2)
        let obs3 = test1.concat(test2)
        print(type(of: obs3))
    }
    
    @objc private func action4(_ sender: UIButton) {
        // concat = map + concat the result of map
        let sequences: [String: Observable<String>] = [
            "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
            "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
        ]
        
        let observable = Observable.of("German cities", "Spanish cities")
            .concatMap { country in sequences[country] ?? .empty() } // Return type was inferred to Observable<String> due to sequences's value. So .empty() means Observable<String>.empty().
        
        observable.subscribe(onNext: {print($0)})
    }
    
    @objc private func action5(_ sender: UIButton) {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        let source = Observable.of(left.asObservable(), right.asObservable())
        let observable = source.merge()
        let disposable = observable.subscribe(onNext: {print($0)})
        
        var leftValues = ["Berlin", "Münich", "Frankfurt"]
        var rightValues = ["Madrid", "Barcelona", "Valencia"]
        repeat {
            switch Bool.random() {
            case true where !leftValues.isEmpty:
                left.onNext("Left: " + leftValues.removeFirst())
            case false where !rightValues.isEmpty:
                right.onNext("Right: " + rightValues.removeFirst())
            default:
                print("break")
                break
            }
        } while !leftValues.isEmpty || !rightValues.isEmpty
        
        left.onCompleted()
        right.onCompleted()
    }
    
    // To undetstand combineLatest, zip and withLatestFrom, watch marbles images. https://medium.com/@martinkonicek/rx-combinelatest-vs-withlatestfrom-ccd98cc1cd41
    @objc private func action6(_ sender: UIButton) {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        let observable = Observable.combineLatest(left, right) { lastLeft, lastRight in
            "\(lastLeft) \(lastRight)"
        }
        let disposable = observable.subscribe(onNext: {print($0)})
        
        print("> Sending a value to Left")
        left.onNext("Hello,")
        print("> Sending a value to Right")
        right.onNext("world")
        print("> Sending another value to Right")
        right.onNext("RxSwift")
        print("> Sending another value to Left")
        left.onNext("Have a good day,")
        
        left.onCompleted()
        right.onCompleted()
        
        //
        
        let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
        let dates = Observable<Date>.of(Date())
        
        let observable_2 = Observable.combineLatest(choice, dates) { format, when -> String in
            let formatter = DateFormatter()
            formatter.dateStyle = format // .short or .long
            return formatter.string(from: when)
        }
        
        _ = observable_2.subscribe(onNext: {print($0)})
    }
    
    @objc private func action7(_ sender: UIButton) {
        enum Weather {
            case cloudy
            case sunny
        }
        let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
        let right: Observable<String> = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
        
        let observable = Observable.zip(left, right) {weather, city -> String in
            return "It's \(weather) in \(city)"
        }
        _ = observable.subscribe(onNext: {print($0)})
    }
    
    @objc private func action8(_ sender: UIButton) {
        let button = PublishSubject<Void>()
        let textField = PublishSubject<String>()
        
        let observable = button.withLatestFrom(textField)
        _ = observable.subscribe(onNext: {print($0)})
        
        textField.onNext("Paris") // Nothing will be printed because textField isn't changed.
        print(1)
        button.onNext(()) // Paris. Because both are changed.
        textField.onNext("New York") // Nothing will be printed because textField isn't changed.
        print(2)
        button.onNext(()) // New York. Because both are changed.
        
        // If you change withLatestFrom to sample, Void will be printed instead of String type.
    }
    
    @objc private func action9(_ sender: UIButton) {
        let left = PublishSubject<String>()
        let right = PublishSubject<String>()
        
        let observable = left.amb(right)
        let disposable = observable.subscribe(onNext: {print($0)})
        
        left.onNext("Lisbon")
        right.onNext("Copenhagen")
        left.onNext("London")
        left.onNext("Madrid")
        right.onNext("Vienna")
        
        left.onCompleted()
        right.onCompleted()
    }
    
    @objc private func action10(_ sender: UIButton) {
        let one = PublishSubject<String>()
        let two = PublishSubject<String>()
        let three = PublishSubject<String>()
        
        let source = PublishSubject<Observable<String>>()
        let observable = source.switchLatest()
        let disposable = observable.subscribe(onNext:{print($0)})
        
        source.onNext(one)
        one.onNext("Some text from sequence one") // O
        two.onNext("Some text from sequence two") // X
        
        source.onNext(two)
        two.onNext("More text from sequence two") // O
        one.onNext("and also from sequence one") // X
        
        source.onNext(three)
        two.onNext("Why don't you see?") // X
        one.onNext("I'm alone, help me") // X
        three.onNext("Hey it's three. I win.") // O
        
        source.onNext(one)
        one.onNext("Nope. It's me, one!") // O
        
        disposable.dispose()
    }
    
    @objc private func action11(_ sender: UIButton) {
        let source = Observable.of(1, 3, 5, 7, 9)
        let observable = source.reduce(0, accumulator: +) // 0 (seed) is starting value.
        _ = observable.subscribe(onNext: {print($0)}) // 25
        
        let observable_2 = source.reduce(3) { summary, newValue in
            return summary + newValue
        }
        _ = observable_2.subscribe(onNext: {print($0)}) // 28
    }
    
    @objc private func action12(_ sender: UIButton) {
        let source = Observable.of(1, 3, 5, 7, 9)
        let observable = source.scan(2, accumulator: +)
        _ = observable.subscribe(onNext: {print($0)}) // 3 6 11 18 27
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
}
