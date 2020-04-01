//
//  SubjectsView.swift
//  Practice
//
//  Created by pook on 1/19/20.
//  Copyright © 2020 pookjw. All rights reserved.
//

import SwiftUI
import RxSwift
import RxRelay

// Definitions

func obsPubSub(){
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?") // Nothing will happen.
    let subscriptionOne = subject
        .subscribe(onNext: {string in
            print(string)
        })
    subject.on(.next("1"))
    subject.onNext("2")
    subscriptionOne.dispose()
    subject.onNext("3") // Nothing will happen.
}

func obsBehvSub(){ // PublishSubject + Initial Value
    var disposeBag = DisposeBag()
    let subject = BehaviorSubject<String>(value: "Hello!")
    let subscription = subject
        .subscribe(onNext: {string in
            Thread.sleep(forTimeInterval: 1.0)
            print("\(string) (1)")
        })
        .disposed(by: disposeBag)
    subject.on(.next("Next 1!"))
    subject
        .subscribe(onNext: {string in
            Thread.sleep(forTimeInterval: 1.0)
            print("\(string) (2)")
        })
        .disposed(by: disposeBag)
    subject.on(.next("Next 2!"))
    disposeBag = DisposeBag()
}

func obsRepSub(){
    enum MyError: Error{
        case ErrorError
    }
    
    var disposeBag = DisposeBag()
    let replaySub = ReplaySubject<String>.create(bufferSize: 4)
    
    replaySub.on(.next("(pre) Event 1"))
    replaySub.on(.next("(pre) Event 2"))
    replaySub.on(.next("(pre) Event 3"))
    replaySub.on(.next("(pre) Event 4"))
    replaySub.on(.next("(pre) Event 5")) // 5 events overfills the buffer.
    
    replaySub
        .subscribe({
            print("Line: \(#line) event: \($0)")
        })
        .disposed(by: disposeBag)
    
    replaySub.on(.next("(post) Event 6"))
    replaySub.onError(MyError.ErrorError)
    replaySub.on(.next("(post) Event 7")) // Nothing will happen.
    disposeBag = DisposeBag()
}

func obsAsyncSub(){ // ReplaySubject + only the last one
    var disposeBag = DisposeBag()
    let asyncSub = AsyncSubject<String>()
    
    asyncSub.on(.next("(pre) Event 1"))
    asyncSub.on(.next("(pre) Event 2"))
    asyncSub.on(.next("(pre) Event 3"))
    
    asyncSub
        .subscribe {
            print($0)
    }
    .disposed(by: disposeBag)
    
    //asyncSub.onCompleted()
    asyncSub.on(.next("(post) Event 4"))
    asyncSub.onCompleted()
    disposeBag = DisposeBag()
}

func obsPubRelay(){
    enum MyError: Error{
        case ErrorError
    }
    
    let relay = PublishRelay<String>()
    let disposeBag = DisposeBag()
    
    relay.accept("Knock Knock, anyone home?")
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
    /* Relay doesn't have .error or .completed.
    relay.accept(MyError.ErrorError)
    relay.completed()*/
}

func obsBehavRelay(){
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    relay.accept("New initial value")
    
    relay
        .subscribe {
            print("1: \($0)")
    }
    .disposed(by: disposeBag)
    
    relay.accept("1")
    
    relay
        .subscribe{
            print("2: \($0)")
    }
    
    relay.accept("2")
}

// End

struct SubjectsView: View {
    @State var showAlert = false
    
    var tipAlert: Alert {
        Alert(title: Text("Tip!"), message: Text("""
            
        """), dismissButton: .default(Text("Dismiss")))
    }
    
    var navBarButton: some View {
        Button(action: {self.showAlert.toggle()}){
            Text("Tip")
        }
    }
    
    var body: some View {
        List{
            Button(action: {obsPubSub()}){ Text("obsPubSub()").foregroundColor(Color.blue)}
            Button(action: {obsBehvSub()}){ Text("obsBehvSub()").foregroundColor(Color.blue)}
            Text("-")
            Button(action: {obsRepSub()}){ Text("obsRepSub()").foregroundColor(Color.blue)}
            Button(action: {obsAsyncSub()}){ Text("obsAsyncSub()").foregroundColor(Color.blue)}
            Text("- RxRelay")
            Button(action: {obsPubRelay()}){ Text("obsPubRelay()").foregroundColor(Color.blue)}
            Button(action: {obsBehavRelay()}){ Text("obsBehavRelay()").foregroundColor(Color.blue)}
            //Button(action: {()}){ Text("()").foregroundColor(Color.blue)}
        }
        .alert(isPresented: $showAlert, content: {tipAlert})
        .navigationBarItems(trailing: navBarButton)
        .navigationBarTitle("Subjects", displayMode: .inline)
    }
}

struct SubjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectsView()
    }
}
