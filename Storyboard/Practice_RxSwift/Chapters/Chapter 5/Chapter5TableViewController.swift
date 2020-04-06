//
//  Chapter5TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class Chapter5TableViewController: UITableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter5TableViewCell", for: indexPath) as! Chapter5TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("ignoreElements", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("elementAt", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("filter", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("skip", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("skipWhile", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("skipUntil", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
        case 7:
            cell.actionButton.setTitle("take", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
        case 8:
            cell.actionButton.setTitle("takeWhile", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action9(_:)), for: .touchUpInside)
        case 9:
            cell.actionButton.setTitle("takeUntil", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action10(_:)), for: .touchUpInside)
        case 10:
            cell.actionButton.setTitle("distinctUntilChanged", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action11(_:)), for: .touchUpInside)
            case 11:
            cell.actionButton.setTitle("distinctUntilChanged (2)", for: .normal)
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
        let strikes = PublishSubject<String>()
        let disposeBag = DisposeBag()
        
        strikes
            .ignoreElements()
            .subscribe { _ in
                print("You're out!")
        }
        .disposed(by: disposeBag)
        
        strikes.onNext("X") // Nothing will be printed.
        strikes.onNext("X") // Nothing will be printed.
        strikes.onNext("X") // Nothing will be printed.
        
        strikes.onCompleted() // You're out!
        
        //
        
        let strikes2 = PublishSubject<String>()
        
        strikes2
            .ignoreElements()
            .subscribe(
                //onNext: { event in } // Extraneous argument label 'onNext:' in call
                onCompleted: { print("2) You're out!") }
        ).disposed(by: disposeBag)
        
        strikes2.onNext("Y") // Nothing will be printed.
        strikes2.onCompleted() // 2) You're out!
    }
    
    @objc private func action3(_ sender: UIButton) {
        let strikes = PublishSubject<String>()
        let disposeBag = DisposeBag()
        
        strikes
            .elementAt(2)
            //.elementAt(4) // Unhandled error happened: Argument out of range.
            .subscribe(
                onNext: { _ in
                    print("You're out!")
            })
            .disposed(by: disposeBag)
        
        strikes.onNext("X") // Nothing will be printed.
        strikes.onNext("X") // You're out!
        strikes.onNext("X") // Nothing will be printed.
        strikes.onNext("X") // Nothing will be printed.
    }
    
    @objc private func action4(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .filter { $0 % 2 == 0 }
            .subscribe(
                onNext: {
                    print($0)
            })
            .disposed(by: disposeBag)
        
        //
        
        let strikes: Observable<String> = Observable.create { observer in
            observer.onNext("A")
            observer.onNext("B")
            observer.onNext("C")
            observer.onCompleted()
            return Disposables.create()
        }
        
        strikes.filter { $0 != "A" }
            .subscribe(
                onNext: {
                    print($0)
            }
        ).disposed(by: disposeBag)
    }
    
    @objc private func action5(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of("A", "B", "C", "D", "E", "F")
            .skip(3)
            .subscribe(
                onNext: {
                    print($0)
            }
        ).disposed(by: disposeBag) // D E F
    }
    
    @objc private func action6(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of(2, 2, 3, 4, 4)
            .skipWhile { $0 % 2 == 0 }
            .subscribe(
                onNext: {
                    print($0) // 3, 4, 4
            }).disposed(by: disposeBag)
    }
    
    @objc private func action7(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
            .skipUntil(trigger)
            .subscribe(
                onNext: {
                    print($0)
            }).disposed(by: disposeBag)
        
        subject.onNext("A") // Nothing will be printed.
        subject.onNext("B") // Nothing will be printed.
        trigger.onNext("A") // Nothing will be printed.
        subject.onNext("C") // C
    }
    
    @objc private func action8(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of(10, 20, 30, 40, 50, 60)
            .take(3) // take(_ count: Int)
            .subscribe(
                onNext: {
                    print($0)
            }
        ).disposed(by: disposeBag)
    }
    
    @objc private func action9(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of(2, 2, 4, 4, 6, 6)
            .enumerated()
            .takeWhile { index, integer in
                integer % 2 == 0 && index < 3
        }.map { $0.element }
            .subscribe (
                onNext: { print($0) }
        ).disposed(by: disposeBag)
        
        //
        
        let subject = PublishSubject<Int>()
        var count = 0
        subject
            .takeWhile { _ in
                count < 3
        }.subscribe(
            onNext: { print("subject: \($0)"); count += 1 },
            onCompleted: { print("subject completed.") }
        ).disposed(by: disposeBag)
        
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3) // automatically completed
        subject.onNext(4)
    }
    
    @objc private func action10(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
            .takeUntil(trigger)
            .subscribe(
                onNext: { print($0) }
        ).disposed(by: disposeBag)
        
        subject.onNext("1") // 1
        subject.onNext("2") // 2
        
        trigger.onNext("X")
        
        subject.onNext("3") // Nothing will be printed.
    }
    
    @objc private func action11(_ sender: UIButton) {
        // If condition is true, ignore that element. (default condition is a == b. if condition is true, `a` isn't changed.)
        
        let disposeBag = DisposeBag()
        
        Observable.of("A", "A", "B", "B", "A", "C", "D", "D")
            .distinctUntilChanged()
            .subscribe(
                onNext: { print($0) }
        ).disposed(by: disposeBag)
        
        Observable<Int>.of(1, 2, 9, 3, 4, 10, 9, 3, 5)
            .distinctUntilChanged { a, b in
                print(a, b)
                return a > b
        }.subscribe(
            onNext: { print($0) }
        ).disposed(by: disposeBag)
    }
    
    @objc private func action12(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
            .distinctUntilChanged { a, b in
                guard let aWords = formatter.string(from: a)?.components(separatedBy: " "), let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    return false
                }
                
                /*
                 formatter.string(from: Int) -> String
                 eg: from: 210 -> "two hundred" (Optional String)
                 
                 .components(separatedBy: " ") -> make it as [String]
                 */
                
                var containsMatch = false
                
                for aWord in aWords where bWords.contains(aWord) {
                    containsMatch = true
                    break
                }
                
                return containsMatch
        }.subscribe(
            onNext: { print($0) }
        ).disposed(by: disposeBag)
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
}
