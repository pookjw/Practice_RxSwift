//
//  Chapter15TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 5/15/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class Chapter15TableViewController: UITableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter15TableViewCell", for: indexPath) as! Chapter15TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("animal", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("fruit", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("subscribeOn", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("observeOn", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("Custom Thread (Animal Thread)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("observeOn (2)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
            case 7:
            cell.actionButton.setTitle("subscribeOn (2)", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
        default:
            ()
        }
        
        return cell
    }
    
    let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    let bag = DisposeBag()
    
    // MARK: Private Methods
    @objc private func action1(_ sender: UIButton) {
        print("Test Action Activated")
    }
    
    @objc private func action2(_ sender: UIButton) {
        let animal = BehaviorSubject(value: "[dog]")
        
        animal
            .subscribeOn(MainScheduler.instance)
            .dump()
            .observeOn(globalScheduler)
            .dumpingSubscription()
            .disposed(by: bag)
    }
    
    @objc private func action3(_ sender: UIButton) {
        let fruit = Observable<String>.create { observer in
            observer.onNext("[apple]")
            sleep(2)
            observer.onNext("[pineapple]")
            sleep(2)
            observer.onNext("[strawberry]")
            
            return Disposables.create()
        }
        
        fruit
            .dump()
            .dumpingSubscription()
            .disposed(by: bag)
    }
    
    @objc private func action4(_ sender: UIButton) {
        let fruit = Observable<String>.create { observer in
            observer.onNext("[apple]")
            sleep(2)
            observer.onNext("[pineapple]")
            sleep(2)
            observer.onNext("[strawberry]")
            
            return Disposables.create()
        }
        
        fruit
            .subscribeOn(globalScheduler)
            .dump()
            .dumpingSubscription()
            .disposed(by: bag)
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 13)) // Prevents killing this process for 13 seconds because subsciption doesn't run on Main Thread.
    }
    
    @objc private func action5(_ sender: UIButton) {
        let fruit = Observable<String>.create { observer in
            observer.onNext("[apple]")
            sleep(2)
            observer.onNext("[pineapple]")
            sleep(2)
            observer.onNext("[strawberry]")
            
            return Disposables.create()
        }
        
        fruit
            .subscribeOn(globalScheduler)
            .dump()
            .observeOn(MainScheduler.instance)
            .dumpingSubscription()
            .disposed(by: bag)
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 13)) // Prevents killing this process for 13 seconds because subsciption doesn't run on Main Thread.
    }
    
    @objc private func action6(_ sender: UIButton) {
        let animal = BehaviorSubject(value: "[dog]")
        
        animal
            //.subscribeOn(MainScheduler.instance)
            .dump()
            //.observeOn(globalScheduler)
            .dumpingSubscription()
            .disposed(by: bag)
        //
        
        let animalsThread = Thread() {
            sleep(3)
            animal.onNext("[cat]")
            sleep(3)
            animal.onNext("[tiger]")
            sleep(3)
            animal.onNext("[fox]")
            sleep(3)
            animal.onNext("[leopard]")
        }
        
        animalsThread.name = "Animals Thread"
        animalsThread.start()
    }
    
    @objc private func action7(_ sender: UIButton) {
        let animal = BehaviorSubject(value: "[dog]")
        
        animal
            //.subscribeOn(MainScheduler.instance)
            .dump()
            .observeOn(globalScheduler)
            .dumpingSubscription()
            .disposed(by: bag)
        //
        
        let animalsThread = Thread() {
            sleep(3)
            animal.onNext("[cat]")
            sleep(3)
            animal.onNext("[tiger]")
            sleep(3)
            animal.onNext("[fox]")
            sleep(3)
            animal.onNext("[leopard]")
        }
        
        animalsThread.name = "Animals Thread"
        animalsThread.start()
    }
    
    @objc private func action8(_ sender: UIButton) {
        let animal = BehaviorSubject(value: "[dog]")
        
        animal
            .subscribeOn(MainScheduler.instance)
            .dump()
            .observeOn(globalScheduler)
            .dumpingSubscription()
            .disposed(by: bag)
        //
        
        let animalsThread = Thread() {
            sleep(3)
            animal.onNext("[cat]")
            sleep(3)
            animal.onNext("[tiger]")
            sleep(3)
            animal.onNext("[fox]")
            sleep(3)
            animal.onNext("[leopard]")
        }
        
        animalsThread.name = "Animals Thread"
        animalsThread.start()
    }
}
