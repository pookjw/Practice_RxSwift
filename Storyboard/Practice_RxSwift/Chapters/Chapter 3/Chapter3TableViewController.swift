//
//  Chapter3TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/2/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class Chapter3TableViewController: UITableViewController {
    
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
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter3TableViewCell", for: indexPath) as! Chapter3TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("PublishSubject", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("BahaviorSubject", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("ReplaySubject", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("AsyncSubject", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
        cell.actionButton.setTitle("PublishRelay", for: .normal)
        cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
            case 6:
            cell.actionButton.setTitle("BehaviorRelay", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
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
        let subject = PublishSubject<String>()
        subject.onNext("Is anyone listening?")
        
        let subscriptionOne = subject
            .subscribe(onNext: {string in
                print(string)
            }
        )
        
        subject.on(.next("1"))
        subject.on(.next("2"))
        
        let subscriptionTwo = subject.subscribe { event in
            print("2)", event.element ?? event)
        }
        
        subject.on(.next("3"))
        
        subscriptionOne.dispose()
        subject.on(.next("4"))
        
        subject.onCompleted()
        subject.onNext("5")
        
        subscriptionTwo.dispose()
        
        let disposeBag = DisposeBag()
        subject.subscribe {
            print("3)", $0.element ?? $0)
        }.disposed(by: disposeBag)
        print("-")
        subject.onNext("?")
    }
    
    private enum MyError: Error {
        case anError
    }
    
    private func print_le<T: CustomStringConvertible>(label: String, event: RxSwift.Event<T>) {
        print("\(label))", (event.element ?? event.error) ?? event)
    }
    
    @objc private func action3(_ sender: UIButton) {
        let subject = BehaviorSubject(value: "Initial value")
        let disposeBag = DisposeBag()
        
        subject.subscribe {
            self.print_le(label: "1", event: $0)
        }.disposed(by: disposeBag)
        
        subject.onNext("X")
        subject.onError(MyError.anError)
        
        subject.subscribe {
            self.print_le(label: "2", event: $0)
        }.disposed(by: disposeBag)
    }
    
    @objc private func action4(_ sender: UIButton) {
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        let disposeBag = DisposeBag()
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("33")
        
        subject.subscribe {
            self.print_le(label: "1", event: $0)
        }.disposed(by: disposeBag)
        
        subject.subscribe {
            self.print_le(label: "2", event: $0)
        }
        
        subject.onNext("4")
        
        subject.subscribe {
            self.print_le(label: "3", event: $0)
        }
        
        subject.onError(MyError.anError)
        
        subject.dispose() // Already dispoed because error threw.
    }
    
    @objc private func action5(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        let asyncSub = AsyncSubject<String>()
        
        asyncSub.on(.next("1"))
        asyncSub.on(.next("2"))
        asyncSub.on(.next("3"))
        
        asyncSub.subscribe {
            self.print_le(label: "1", event: $0)
        }.disposed(by: disposeBag)
        
        asyncSub.on(.next("4"))
        asyncSub.onCompleted()
    }
    
    @objc private func action6(_ sender: UIButton) {
        // In PublishRelay, it doesn't have next, error and completed events; it only has accept.
        let relay = PublishRelay<String>()
        let disposeBag = DisposeBag()
        
        relay.accept("1")
        
        relay.subscribe(onNext: {
            print($0)
        }
        ).disposed(by: disposeBag)
        
        relay.accept("2")
        //relay.accept(MyError.anError)
    }
    
    @objc private func action7(_ sender: UIButton) {
        // In BehaviorRelay, it doesn't have next, error and completed events; it only has accept.
        let relay = BehaviorRelay<String>(value: "Initial value")
        let disposeBag = DisposeBag()
        
        relay.accept("1")
        
        relay.subscribe(onNext: {
            print($0)
        }
        ).disposed(by: disposeBag)
        
        relay.accept("2")
        //relay.accept(MyError.anError)
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
    
}
