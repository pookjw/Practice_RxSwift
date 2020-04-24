//
//  Chapter7TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/6/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift

class Chapter7TableViewController: UITableViewController {
    
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
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter7TableViewCell", for: indexPath) as! Chapter7TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("toArray", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("map", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("enumerated and map", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("flatMap", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("flatMapLatest", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("materialize", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
        case 7:
            cell.actionButton.setTitle("dematerialize", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
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
        let disposeBag = DisposeBag()
        
        Observable.of("A", "B", "C")
            .toArray()
            .subscribe(
                {
                    print($0)
                }
        )
            .disposed(by: disposeBag)
    }
    
    @objc private func action3(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        Observable<Int>.of(123, 4, 56)
            .map {
                formatter.string(for: $0) ?? ""
        } // Convert to String
            .subscribe {
                print($0)
        }.disposed(by: disposeBag)
    }
    
    @objc private func action4(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .enumerated()
            .map { index, integer in
                index > 2 ? integer * 2 : integer
        }
        .subscribe(
            onNext: {
                print($0)
        }
        ).disposed(by: disposeBag)
    }
    
    struct Student {
        let score: BehaviorSubject<Int>
    }
    
    @objc private func action5(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = PublishSubject<Student>()
        
        student
            .flatMap {
                $0.score
        }
        .subscribe(
            onNext: { print($0) }
        ).disposed(by: disposeBag)
        
        student.onNext(laura) // 80
        laura.score.onNext(85) // 85. This is the difference between .map and .flatMap.
        
        student.onNext(charlotte) // 90
        laura.score.onNext(95) // 95. ''
        
        charlotte.score.onNext(100) // 100
    }
    
    @objc private func action6(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 90))
        
        let student = PublishSubject<Student>()
        
        student
            .flatMapLatest {
                $0.score
        }
        .subscribe(
            onNext: {
                print($0)
        }
        )
            .disposed(by: disposeBag)
        
        student.onNext(laura) // 80
        laura.score.onNext(85) // 85
        student.onNext(charlotte) // 90
        
        laura.score.onNext(95) // Nothing will be printed.
        charlotte.score.onNext(100) // 100. This is the difference between .flatMap and .flatMapLatest.
    }
    
    enum MyError: Error {
        case anError
    }
    
    @objc private func action7(_ sender: UIButton) {
        // normal
        let disposeBag = DisposeBag()
        
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 100))
        
        let student = BehaviorSubject(value: laura)
        let studentScore = student.flatMapLatest { $0.score }
        
        studentScore
            .subscribe(
                onNext: { print($0) }
        ).disposed(by: disposeBag) // 80
        
        laura.score.onNext(85) // 85
        laura.score.onError(MyError.anError) // Unhandled error happened: anError
        laura.score.onNext(90) // Nothing will be printed.
        
        student.onNext(charlotte) // *Nothing will be printed.
        
        // materialize
        // studentScore, student, laura, and charlotte has error so cannot be reused.
        let laura_2 = Student(score: BehaviorSubject(value: 80))
        let charlotte_2 = Student(score: BehaviorSubject(value: 100))
        let student_2 = BehaviorSubject(value: laura_2)
        let studentScore_2 = student_2.flatMapLatest { $0.score.materialize() }
        
        studentScore_2
            .subscribe(
                onNext: { print($0) }
        ).disposed(by: disposeBag) // next(80). It's Event<Int>, not Int.
        
        laura_2.score.onNext(85) // next(85)
        laura_2.score.onError(MyError.anError) // error(anError)
        laura_2.score.onNext(90) // Nothing will be printed.
        
        student_2.onNext(charlotte_2) // *next(100)
    }
    
    @objc private func action8(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 100))
        
        let student = BehaviorSubject(value: laura)
        let studentScore = student.flatMapLatest { $0.score.materialize() }
        
        studentScore
            .filter {
                guard $0.error == nil else {
                    return false
                }
                return true
        }
        .dematerialize()
        .subscribe(
            onNext: {
                print($0)
        }
        ).disposed(by: disposeBag)
        
        laura.score.onNext(80) // 80
        laura.score.onError(MyError.anError) // Ignored by filter.
        laura.score.onNext(90) // Nothing will be printed.
        
        student.onNext(charlotte) // 100
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
}
