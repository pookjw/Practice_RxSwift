//
//  Practice.swift
//  Practice_RxSwift2
//
//  Created by pook on 6/25/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RxSwift

var disposeBag: DisposeBag = DisposeBag()

let Practice: [(name: String, foo: () -> ())] = [
    ("Chapter 2 - Observable", {
        let obs1: Observable = Observable<Int>.just(3)
        let obs2: () = Observable<Int>.of(1, 2, 3)
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        let obs3: Disposable = Observable<[Int]>.of([1, 2, 3])
            .subscribe { print($0) }
        let obs4: Disposable = Observable<Int>.from([1, 2, 3])
            .subscribe { print($0) }
        
        let sequence = 0..<3
        var iterator = sequence.makeIterator()
        while let n = iterator.next() {
            print(n)
        }
        
        let obs5: Disposable = Observable<Void>.empty()
            .subscribe { print("Empty") }
        let obs6: Disposable = Observable<Any>.never()
            .subscribe { print("Never") } // Nothing
        
        let obs7: Disposable = Observable<Int>.range(start: 1, count: 10)
            .subscribe(
                onNext: { print($0) },
                onDisposed: { print("Disposed!") }
        )
        obs7.dispose()
        
        let obs8 = Observable<String>.create { observer in
            observer.on(.next("Hi!"))
            observer.onNext("Hello!")
            observer.onCompleted()
            
            return Disposables.create {
                print("D1")
            }
        }
        .subscribe(
            onNext: { print($0) },
            onDisposed: { print("D2") }
        )
            .disposed(by: disposeBag)
        
        let boolean = true
        let obs9 = Observable<Int>.deferred {
            if boolean {
                return Observable.from([1, 2, 3])
            } else {
                return Observable.of(4, 5, 6)
            }
        }
        .subscribe { print($0) }
    }),
    
    ("[Traits] Single, Maybe and Completable", {
        // Event (onSuccess, onError 등) 중에서 1개만 발생하고 끝남 (onSuccess가 여러번 될 수도 없음)
        print("--- Single ---")
        // onSuccess, onError
        let single1 = Single<Int>.create { single in
            single(.success(3))
            single(.error(TestError.One))
            return Disposables.create()
        }
        
        single1.subscribe(
            onSuccess: { print($0) }, // 3
            onError: { print($0.localizedDescription) } // Nothing
        )
        single1.subscribe(
            onSuccess: { print($0) }, // 3
            onError: { print($0.localizedDescription) } // Nothing
        )
        
        print("--- Completable ---")
        // onCompleted, onError
        let completable1 = Completable.create { completable in
            completable(.completed)
            completable(.error(TestError.One)) // Won't happen because .completed occured.
            return Disposables.create()
        } // It doesn't have value, so doesn't require Generic Type.
        
        completable1.subscribe(onCompleted: { print("onCompleted") }, onError: { print($0.localizedDescription) })
        
        print("--- Maybe ---")
        let maybe1 = Maybe<Int>.create { maybe in
            maybe(.success(1))
            maybe(.completed)
            maybe(.error(TestError.One))
            
            return Disposables.create()
        }
        maybe1.subscribe(onSuccess: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("onCompleted") })
    }),
    
    ("Chapter 2 - Challenge 1: Perform side effects (1)", {
        print("--- do with empty ---")
        let obs1 = Observable<Int>.empty()
            .do(onNext: { print("onNext \($0)") },
                afterNext: { print("afterNext \($0)") },
                onError: { print("onError \($0.localizedDescription)") },
                afterError: { print("afterError \($0.localizedDescription)") },
                onCompleted: { print("onCompleted") },
                afterCompleted: { print("afterCompleted") },
                onSubscribe: { print("onSubscribe") },
                onSubscribed: { print("onSubscribed") },
                onDispose: { print("onDispose") })
        
        obs1.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("comp") }, onDisposed: { print("disp") })
    }),
    
    ("Chapter 2 - Challenge 1: Perform side effects (2)", {
        print("--- do with values ---")
        let obs2 = Observable<Int>.create { observer in
            observer.onNext(1)
            observer.onNext(2)
            observer.onCompleted()
            return Disposables.create()
        }
        .do(onNext: { print("onNext \($0)") },
            afterNext: { print("afterNext \($0)") },
            onError: { print("onError \($0.localizedDescription)") },
            afterError: { print("afterError \($0.localizedDescription)") },
            onCompleted: { print("onCompleted") },
            afterCompleted: { print("afterCompleted") },
            onSubscribe: { print("onSubscribe") },
            onSubscribed: { print("onSubscribed") },
            onDispose: { print("onDispose") })
        
        obs2.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("comp") }, onDisposed: { print("disp") })
        //        Thread.sleep(forTimeInterval: 1.0)
    }),
    
    ("Chapter 2 - Challenge 1: Perform side effects (3)", {
        print("--- do with never ---")
        let obs1 = Observable<Int>.never()
            .do(onNext: { print("onNext \($0)") },
                afterNext: { print("afterNext \($0)") },
                onError: { print("onError \($0.localizedDescription)") },
                afterError: { print("afterError \($0.localizedDescription)") },
                onCompleted: { print("onCompleted") },
                afterCompleted: { print("afterCompleted") },
                onSubscribe: { print("onSubscribe") },
                onSubscribed: { print("onSubscribed") },
                onDispose: { print("onDispose") })
        
        obs1.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("comp") }, onDisposed: { print("disp") })
    }),
    
    ("Chapter 2 - Challenge 1: Perform side effects (4 - .debug())", {
        print("--- do with values ---")
        let obs2 = Observable<Int>.create { observer in
            observer.onNext(1)
            observer.onNext(2)
            observer.onCompleted()
            return Disposables.create()
        }
        .do(onNext: { print("onNext \($0)") },
            afterNext: { print("afterNext \($0)") },
            onError: { print("onError \($0.localizedDescription)") },
            afterError: { print("afterError \($0.localizedDescription)") },
            onCompleted: { print("onCompleted") },
            afterCompleted: { print("afterCompleted") },
            onSubscribe: { print("onSubscribe") },
            onSubscribed: { print("onSubscribed") },
            onDispose: { print("onDispose") })
            .debug()
        
        obs2.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("comp") }, onDisposed: { print("disp") })
        //        Thread.sleep(forTimeInterval: 1.0)
    }),
    
    ("Chapter 3 - Subjects", {
        print("--- PublishSubject ---")
        let subj1 = PublishSubject<String>()
        subj1.onNext("A")
        subj1.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("onCompleted") }, onDisposed: { print("onDisposed") })
        subj1.onNext("B")
        subj1.on(.completed)
        
        print("--- BehaviorSubject ---")
        let subj2 = BehaviorSubject<Int>(value: 1)
        subj2.onNext(2)
        subj2.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("onCompleted") }, onDisposed: { print("onDisposed") })
        subj2.onNext(3)
        subj2.on(.completed)
        
        print("--- ReplaySubject ---")
        let subj3 = ReplaySubject<Int>.create(bufferSize: 3)
        subj3.onNext(1)
        subj3.onNext(2)
        subj3.onNext(3)
        subj3.onNext(4)
        subj3.onNext(5)
        subj3.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("onCompleted") }, onDisposed: { print("onDisposed") })
        subj3.onNext(100)
        subj3.on(.completed)
        
        print("--- AsyncSubject ---")
        // Emis only the last .next event in the sequence, and only when the subject receives a .completed event.
        let subj4 = AsyncSubject<Int>()
        subj4.onNext(1)
        subj4.onNext(2)
        subj4.onNext(3)
        subj4.onNext(4)
        subj4.subscribe(onNext: { print($0) }, onError: { print($0.localizedDescription) }, onCompleted: { print("onCompleted") }, onDisposed: { print("onDisposed") })
        subj4.onNext(100)
        subj4.onNext(200) // Only this!
        subj4.on(.completed)
    }),
    
    ("Chapter 5 - Filtering Operators", {
        print("--- ignoreElements ---")
        let subj1 = PublishSubject<Int>()
        subj1
            .ignoreElements()
            .subscribe { print("\($0) sub1") }
        subj1.onNext(3) // Ignored
        
        print("--- elementAt ---")
        let subj2 = PublishSubject<Int>()
        subj2
            .elementAt(2)
            .subscribe { print($0) }
        subj2.onNext(100)
        subj2.onNext(200)
        subj2.onNext(300) // Only this; event completed
        subj2.onNext(400)
        subj2.onNext(500)
        subj2.onNext(600)
        
        print("--- filter ---")
        let obs1 = Observable.of(1, 2, 3, 4, 5, 6)
            .filter { $0 % 2 == 0 }
            .subscribe { print($0) }
        
        print("--- skip ---")
        let obs2 = Observable.of("A", "B", "C", "D", "E", "F")
            .skip(3)
            .subscribe { print($0) }
        
        print("--- skipWhile ---")
        let obs3 = Observable<Int>.from([1, 2, 3, 4, 5])
            .skipWhile { $0 % 2 == 1 } // 1 will be skipped
            .subscribe { print($0) }
        
        print("--- skipUntil ---")
        let subj3 = PublishSubject<Int>()
        let subj4 = PublishSubject<Int>()
        
        subj3
            .subscribe { print($0) }
        subj4
            .skipUntil(subj3)
            .subscribe { print($0) }
        
        subj4.onNext(1)
        subj4.onNext(2)
        subj4.onNext(3)
        
        subj3.onNext(100)
        
        subj4.onNext(300)
        
        print("--- take ---")
        let obs4 = Observable<Int>.of(1, 2, 3, 4, 5, 6)
        obs4
            .take(3) // After taking 3 element, event completed
            .subscribe { print($0) }
        
        print("--- takeWhile ---")
        let obs5 = Observable<Int>.of(1, 2, 3, 4, 5, 6)
        obs5
            .takeWhile { $0 < 3 }
            .subscribe { print($0) }
        
        print("--- enumerated ---")
        let obs6 = Observable<Int>.of(2, 2, 4, 4, 6, 6)
        obs6
            .enumerated() // Transform <Int> to <(index: Int, element: Int)>
            .takeWhile { index, integer in
                integer % 2 == 0 && index < 3
        }
        .subscribe { print($0) }
        
        print("--- takeUntil ---")
        let subj5 = PublishSubject<Int>()
        let subj6 = PublishSubject<Int>()
        
        subj6
            .takeUntil(subj5)
            .subscribe { print($0) }
        subj6.onNext(1)
        subj6.onNext(2)
        subj6.onNext(3)
        
        subj5
            .subscribe { print($0) }
        subj5.onNext(100)
        
        subj6.onNext(200)
        
        // with RxCocoa, you can collaborate like: .takeUntil(self.rx.deallocated)
        
        print("--- distinctUntilChanged (1) ---")
        let obs7 = Observable.of(1, 1, 2, 2, 3, 4, 5, 5, 6)
        obs7
            .distinctUntilChanged()
            .subscribe { print($0) }
        
        print("--- distinctUntilChanged (2) ---")
        let obs8 = Observable.of(1, 1, 2, 2, 3, 4, 5, 5, 6)
        obs8
            .distinctUntilChanged({ print($0, $1); return $0.hashValue != $1.hashValue })
            .subscribe { print($0) }
    }),
    
    ("Chapter 7 - Transforming Operators", {
        print("--- toArray ---")
        let obs1 = Observable.of("A", "B", "C")
            .toArray() // Transform to Single<[String]>
            .subscribe { print($0) }
        
        print("--- map (1) ---")
        let obs2 = Observable.of(1, 2, 3)
            .map { $0 * 2 }
            .subscribe { print($0.element) }
        
        let obs3 = Observable.of("A", "B")
        
        print("--- map (2) ---")
        let obs4 = Observable.of(100, 200, 300)
            .enumerated()
            .map { index, integer in
                index > 1 ? integer * 2 : integer
        }
        .subscribe { print($0) }
        
        print("--- flatMap ---")
        struct Student {
            let score: BehaviorSubject<Int>
        }
        let laura = Student(score: BehaviorSubject(value: 80))
        let charlotte = Student(score: BehaviorSubject(value: 80))
        let student1 = PublishSubject<Student>()
        
        let disp1 = student1
            .flatMap { $0.score }
            .subscribe { print($0) }
        
        student1.onNext(laura)
        laura.score.onNext(85)
        student1.onNext(charlotte)
        charlotte.score.onNext(100)
        laura.score.onNext(200)
        disp1.dispose()
        
        print("--- flatMapFirst ---")
        let disp2 = student1
            .flatMapFirst { $0.score }
            .subscribe { print($0) }
        
        student1.onNext(laura)
        laura.score.onNext(300)
        student1.onNext(charlotte)
        charlotte.score.onNext(500)
        laura.score.onNext(600)
        disp2.dispose()
        
        print("--- flatMapLatest ---")
        let disp3 = student1
            .flatMapLatest { $0.score }
            .subscribe { print($0) }
        student1.onNext(laura)
        laura.score.onNext(300)
        student1.onNext(charlotte)
        charlotte.score.onNext(500)
        laura.score.onNext(600)
        disp3.dispose()
        
        // Watch Error carefully on materialized, or not
        
        print("--- flatMap with Error ---")
        let disp4 = student1
            .flatMap { $0.score }
            .subscribe { print($0) }
        student1.onNext(laura)
        laura.score.onNext(300)
        student1.onNext(charlotte)
        charlotte.score.onNext(500)
        charlotte.score.onError(TestError.One)
        charlotte.score.onNext(550)
        laura.score.onNext(600)
        disp4.dispose()
        
        print("--- materialize ---")
        let disp5 = student1
            .flatMapLatest { $0.score.materialize() }
            .subscribe { print($0) }
        student1.onNext(laura)
        laura.score.onNext(300)
        student1.onNext(charlotte)
        charlotte.score.onNext(500)
        charlotte.score.onError(TestError.One)
        charlotte.score.onNext(550)
        laura.score.onNext(600)
        disp5.dispose()
        
        print("--- dematerialize ---")
        let disp6 = student1
            .flatMapLatest { $0.score.materialize().materialize().dematerialize().dematerialize() }
            .subscribe { print($0) }
        student1.onNext(laura)
        laura.score.onNext(300)
        student1.onNext(charlotte)
        charlotte.score.onNext(500)
        laura.score.onNext(600)
        disp6.dispose()
    }),
    
    ("Chapter 9 - Combining Operators", {
        print("--- startWith ---")
        let obs1 = Observable.of(2, 3, 4)
        obs1
            .startWith(1)
            .subscribe { print($0) }
        
        print("--- concat ---")
        let obs2 = Observable.of(1, 2, 3)
        let obs3 = Observable.of(4, 5, 6)
        let obs4 = obs2.concat(obs3)
        obs4
            .subscribe { print($0) }
        
        print("--- concatMap ---")
        let sequences = [
            "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
            "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
        ]
        let obs5 = Observable.of("German cities", "Spanish cities")
            .concatMap { country in sequences[country] ?? .empty() }
        obs5.subscribe { print($0) }
        
        print("--- merge ---")
        let subj1 = PublishSubject<String>()
        let subj2 = PublishSubject<String>()
        let source = Observable.of(subj1.asObservable(), subj2.asObservable())
        source
            .merge()
            .subscribe { print($0) }
        
        subj1.onNext("A")
        subj2.onNext("B")
        
        print("--- combineLatest (1) ---")
        let subj3 = PublishSubject<String>()
        let subj4 = PublishSubject<String>()
        let obs6 = Observable.combineLatest(subj3, subj4) // ($0, $1) <(String, String)>
        let disp1 = obs6.subscribe { print($0) }
        
        subj3.onNext("A")
        subj4.onNext("B")
        subj3.onNext("C")
        disp1.dispose()
        
        print("--- combineLatest (2) ---")
        let obs7 = Observable.combineLatest(subj3, subj4) { "\($0) \($1)" } // <String>
        let disp2 = obs7.subscribe { print($0) }
        
        subj3.onNext("A")
        subj4.onNext("B")
        subj3.onNext("C")
        disp2.dispose()
        
        print("--- combineLatest (3) ---")
        let obs8 = Observable.combineLatest([subj3, subj4]) // [$0, $1] <[String, String]>
        let disp3 = obs8.subscribe { print($0) }
        
        subj3.onNext("A")
        subj4.onNext("B")
        subj3.onNext("C")
        disp3.dispose()
        
        print("--- combineLatest (4) ---")
        let obs9 = Observable.combineLatest([subj3, subj4]) { $0.joined(separator: " ") } // <String>
        let disp4 = obs9.subscribe { print($0) }
        
        subj3.onNext("A")
        subj4.onNext("B")
        subj3.onNext("C")
        disp4.dispose()
        
        print("--- zip (1) ---")
        enum Weather {
            case cloudy, sunny
        }
        let obs10 = Observable<Weather>.of(.sunny, .cloudy, .cloudy, .sunny)
        let obs11 = Observable<String>.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
        let obs12 = Observable.zip(obs10, obs11) { "It's \($0) in \($1)" }
        let disp5 = obs12.subscribe { print($0) }
        disp5.dispose()
        
        print("--- zip (2) ---")
        let subj5 = PublishSubject<Weather>()
        let subj6 = PublishSubject<String>()
        let obs13 = Observable.zip(subj5, subj6) { "It's \($0) in \($1)" }
        let disp6 = obs13.subscribe { print($0) }
        subj5.onNext(.sunny)
        subj5.onNext(.cloudy)
        subj6.onNext("Lisbon")
        subj6.onNext("Copenhagen")
        subj6.onNext("London")
        subj5.onNext(.cloudy)
        subj6.onNext("Madrid")
        subj5.onNext(.sunny)
        disp6.dispose()
    })
]
