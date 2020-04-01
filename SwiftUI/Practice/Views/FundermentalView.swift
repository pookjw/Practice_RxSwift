//
//  FundermentalView.swift
//  Practice
//
//  Created by pook on 1/19/20.
//  Copyright © 2020 pookjw. All rights reserved.
//

import SwiftUI
import RxSwift

// Definitions

let one = 1
let two = 2
let three = 3

func obsJust(){
    let observable1 = Observable<Int>.just(one)
}

func obsOf(){
    let observable2 = Observable<Int>.of(one, two, three)
    let observable3 = Observable<[Int]>.of([one, two, three])
    observable2.subscribe { n in print("2: \(n)")}
    observable3.subscribe { n in print("3: \(n)")}
}

func obsFrom(){
    let observable4 = Observable<Int>.from([one, two, three])
    observable4.subscribe { n in print("4: \(n)")}
}

func obsElement(){
    let observable5 = Observable<Int>.from([one, two, three])
    observable5.subscribe { n in print("5: \(n.element)")} // the last one is nil because "completed" is nil Event.
    observable5.subscribe { event in
        if let element = event.element{
            print("5: \(element)")
        }
    }
}

func obsVoid(){
    let observable6 = Observable<Void>.empty()
    observable6
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
        .subscribe {
            for _ in 0...2{
                Thread.sleep(forTimeInterval: 1.0)
                print("Hello from observable6!")
            }
    }
}

func obsComplete(){
    let observable7 = Observable<Int>.from([one, two, three])
    observable7.subscribe(
        onNext: {n in print("7: \(n)")},
        onCompleted: {print("observable7 was done!")}
    )
}

func obsNever(){
    let observable8 = Observable<Any>.never()
    observable8.subscribe(
        onNext: {element in print("8: \(element)")},
        onCompleted: {print("observable8 was done!")}
    )
}

func obsRange(){
    let observable9 = Observable<Int>.range(start: 1, count: 10)
    observable9.subscribe(
        onNext: { i in print("9: \(i)")}
    )
    observable9.subscribe(
        onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
            print("9: Fibonacci - \(fibonacci)")
    }
    )
}

func obsDispose(){
    let observable10 = Observable.of("A", "B", "C")
    let subscription = observable10.subscribe { event in print("10: \(event)") }
    subscription.dispose()
    
    var disposeBag = DisposeBag()
    
    let observable11 = Observable.of("A", "B", "C")
    observable11.subscribe { print("11: \($0)") }
        .disposed(by: disposeBag)
    disposeBag = DisposeBag()
    
    let observable12 = Observable<String>.create { observer in
        observer.onNext("1")
        observer.onCompleted()
        observer.onNext("?")
        return Disposables.create()
    }
    observable12
        .subscribe(
            onNext: {print("12: \($0)")},
            onError: {print("12: \($0)")},
            onCompleted: {print("observable12 was done!")},
            onDisposed: {print("observable12 was disposed!")}
    )
        .disposed(by: disposeBag)
}

func obsError(){
    enum MyError: Error{
        case anError
    }
    let observable13 = Observable<String>.create {
        $0.onNext("1")
        $0.onError(MyError.anError)
        $0.onCompleted()
        return Disposables.create()
    }
    observable13
        .subscribe(
            onNext: {print("13: \($0)")},
            onError: {print("13: \($0)")},
            onCompleted: {print("obervable13 was done!")},
            onDisposed: {print("observable13 was disposed!")}
    )
}

// End

struct FundermentalView: View {
    @State var showAlert = false
    
    var tipAlert: Alert {
        Alert(title: Text("Tip!"), message: Text("""
            1. obsFrom gives Event<Int>, but obsComplete gives Int because obsComplete uses onNext: {}.
            2. After onError, onCompleted is ignored.
        """), dismissButton: .default(Text("Dismiss")))
    }
    
    var navBarButton: some View {
        Button(action: {self.showAlert.toggle()}){
            Text("Tip")
        }
    }
    
    var body: some View {
        List{
            Button(action: {obsJust()}){ Text("obsJust()").foregroundColor(Color.blue)}
            Button(action: {obsOf()}){ Text("obsOf()").foregroundColor(Color.blue)}
            Button(action: {obsFrom()}){ Text("obsFrom()").foregroundColor(Color.blue)}
            Button(action: {obsElement()}){ Text("obsElement()").foregroundColor(Color.blue)}
            Button(action: {obsVoid()}){ Text("obsVoid()").foregroundColor(Color.blue)}
            Button(action: {obsComplete()}){ Text("obsComplete()").foregroundColor(Color.blue)}
            Button(action: {obsNever()}){ Text("obsNever()").foregroundColor(Color.blue)}
            Button(action: {obsRange()}){ Text("obsRange()").foregroundColor(Color.blue)}
            Button(action: {obsDispose()}){ Text("obsDispose()").foregroundColor(Color.blue)}
            Button(action: {obsError()}){ Text("obsError()").foregroundColor(Color.blue)}
            //Button(action: {()}){ Text("()").foregroundColor(Color.blue)}
        }
        .alert(isPresented: $showAlert, content: {tipAlert})
        .navigationBarItems(trailing: navBarButton)
        .navigationBarTitle("FundermentalView", displayMode: .inline)
    }
}

struct FundermentalView_Previews: PreviewProvider {
    static var previews: some View {
        FundermentalView()
    }
}
