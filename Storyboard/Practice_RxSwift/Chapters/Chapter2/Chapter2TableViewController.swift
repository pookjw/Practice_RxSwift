//
//  Chapter2TableViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 3/31/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift

class Chapter2TableViewController: UITableViewController {
    
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
        return 13
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter2TableViewCell", for: indexPath) as! Chapter2TableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.actionButton.setTitle("Test Action", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action1(_:)), for: .touchUpInside)
        case 1:
            cell.actionButton.setTitle("just", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action2(_:)), for: .touchUpInside)
        case 2:
            cell.actionButton.setTitle("of", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action3(_:)), for: .touchUpInside)
        case 3:
            cell.actionButton.setTitle("from", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action4(_:)), for: .touchUpInside)
        case 4:
            cell.actionButton.setTitle("empty & onNext + onCompleted", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action5(_:)), for: .touchUpInside)
        case 5:
            cell.actionButton.setTitle("never", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action6(_:)), for: .touchUpInside)
        case 6:
            cell.actionButton.setTitle("range", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action7(_:)), for: .touchUpInside)
        case 7:
            cell.actionButton.setTitle("fibonacci with range", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action8(_:)), for: .touchUpInside)
        case 8:
            cell.actionButton.setTitle("DisposeBag", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action9(_:)), for: .touchUpInside)
        case 9:
            cell.actionButton.setTitle("create", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action10(_:)), for: .touchUpInside)
        case 10:
            cell.actionButton.setTitle("deferred", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action11(_:)), for: .touchUpInside)
        case 11:
            cell.actionButton.setTitle("Single", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action12(_:)), for: .touchUpInside)
        case 12:
            cell.actionButton.setTitle("[Challenge 1] do ", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.action13(_:)), for: .touchUpInside)
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
        let one = 1
        let two = 2
        let three = 3
        
        let observable = Observable<Int>.just(one) // or you can remove <Int> because it's inferrable.
        observable.subscribe {
            print($0)
        }
    }
    
    @objc private func action3(_ sender: UIButton) {
        let one = 1
        let two = 2
        let three = 3
        
        let observable = Observable<Int>.of(one, two, three)
        observable.subscribe { event in
            print(event.element)
            print(event)
        } // The last one of event element is nil because that is Completed Event.
    }
    
    @objc private func action4(_ sender: UIButton) {
        let one = 1
        let two = 2
        let three = 3
        
        let observable = Observable.from([one, two, three])
        observable.subscribe {
            print($0)
            print($0.element)
        }
    }
    
    @objc private func action5(_ sender: UIButton) {
        let observable = Observable<Void>.empty()
        observable.subscribe (
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed!")
        }
        )
    }
    
    @objc private func action6(_ sender: UIButton) {
        var disposeBag = DisposeBag()
        
        let observable = Observable<Any>.never()
        observable.subscribe (
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed!")
        },
            onDisposed: {
                print("Disposed!")
        }
        ).disposed(by: disposeBag)
        
        disposeBag = DisposeBag()
    }
    
    @objc private func action7(_ sender: UIButton) {
        let observable = Observable<Int>.range(start: 1, count: 10)
        observable.subscribe (
            onNext: { event in
                print(event)
        },
            onCompleted: {
                print("Completed!") // In range, there's no onCompleted action by default.
        }
        )
    }
    
    @objc private func action8(_ sender: UIButton) {
        let observable = Observable<Int>.range(start: 1, count: 10)
        observable.subscribe (
            onNext: { i in
                let n = Double(i)
                let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
                print(fibonacci)
        }
        )
    }
    
    @objc private func action9(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        let observable = Observable.of("A", "B", "C")
        let subscription = observable.subscribe { event in
            print(event.element)
        }.disposed(by: disposeBag)
    }
    
    @objc private func action10(_ sender: UIButton) {
        enum MyError: Error {
            case anError
        }
        
        var disposeBag = DisposeBag()
        let observable = Observable<String>.create { observer in
            observer.onNext("1")
            observer.onCompleted() // If .onCompleted isn't occured, it results of memory leak.
            observer.onNext("?") // it will be ignored because onCompleted occured.
            observer.onError(MyError.anError) // it will be ignored because onCompleted occured.
            return Disposables.create()
        }
        observable.subscribe (
            onNext: { print($0) }, // $0 is not Event type, it's String.
            onError: {print($0) },
            onCompleted: { print("Completed!") },
            onDisposed: { print("Disposed!") }
        ).disposed(by: disposeBag)
        
        disposeBag = DisposeBag() // Disposed!
    }
    
    @objc private func action11(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        var flip = false
        
        let factory: Observable<Int> = Observable.deferred {
            flip.toggle()
            
            if flip {
                return Observable.of(1, 2, 3)
            } else {
                return Observable.of(4, 5, 6)
            }
        }
        
        for _ in 0...3 {
            factory.subscribe (
                onNext: {
                    print($0, terminator: "")
            }
            ).disposed(by: disposeBag)
            print()
        }
        
        
        let factory_withoyt_deferred: Observable<Int> = Observable.create { observer in
            flip.toggle()
            
            if flip {
                observer.onNext(1)
                observer.onNext(2)
                observer.onNext(3)
            } else {
                observer.onNext(4)
                observer.onNext(5)
                observer.onNext(6)
            }
            
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        for _ in 0...3 {
            factory_withoyt_deferred.subscribe(
                onNext: {print($0, terminator: "")}
            )
            print()
        }
        
        factory_withoyt_deferred.subscribe {
            switch $0 {
            default:
                print($0)
            }
        }
    }
    
    @objc private func action12(_ sender: UIButton) {
        let disposeBag = DisposeBag()
        
        enum FileReadError: Error {
            case fileNotFound, unreadable, encodingFailed
        }
        
        func loadText(from name: String) -> Single<String> {
            return Single.create { single in
                let disposable = Disposables.create()
                
                guard let path: String = Bundle.main.path(forResource: name, ofType: "txt") else {
                    single(.error(FileReadError.fileNotFound))
                    return disposable
                }
                
                guard let data = FileManager.default.contents(atPath: path) else {
                    single(.error(FileReadError.unreadable))
                    return disposable
                }
                
                guard let contents = String(data: data, encoding: .utf8) else {
                    single(.error(FileReadError.encodingFailed))
                    return disposable
                }
                
                single(.success(contents))
                
                return disposable
            }
        }
        
        loadText(from: "test").subscribe{
            switch $0 {
            case .success(let string):
                print(string)
            case.error(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
    }
    
    @objc private func action13(_ sender: UIButton) {
        var disposeBag = DisposeBag()
        Observable.of(1,2,3,4,5).do(
            onNext: {
                $0 * 10
                // $0 = $0 * 10 // $0 is immutable
                print("do: \($0)")
        }
        ).subscribe(
            onNext: {
                print("subscribe: \($0)")
        }
        ).disposed(by: disposeBag)
        
        print("-")
        
        Observable<Any>.never().do(
            onNext: {print("do onNext: \($0)")},
            onCompleted: {print("do onCompleted")},
            onDispose: {print("do onDispose")}
        ).subscribe(
            onNext: {print("subscribe onNext: \($0)")},
            onCompleted: {print("subscribe onCompleted")},
            onDisposed: {print("subscribe onDisposed")}
        ).disposed(by: disposeBag)
        
        disposeBag = DisposeBag()
    }
    
    @objc private func action(_ sender: UIButton) {
        
    }
}
