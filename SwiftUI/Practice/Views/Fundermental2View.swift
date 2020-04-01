//
//  Fundermental2View.swift
//  Practice
//
//  Created by pook on 1/19/20.
//  Copyright © 2020 pookjw. All rights reserved.
//

import SwiftUI
import RxSwift

// Definitions

// About Defer: http://reactivex.io/documentation/operators/defer.html
func obsDefer(){
    let disposeBag = DisposeBag()
    var flip = false
    let factory: Observable<Int> = Observable.deferred {
        flip.toggle()
        if flip{
            return Observable.of(1, 2, 3)
        }else{
            return Observable.of(4,5,6)
        }
    }
    
    for _ in 0...3{
        factory
            .subscribe(onNext:{print("factory: \($0)", terminator: ", ")})
            .disposed(by: disposeBag)
        print()
    }
}

func obsSingle(){
    let disposeBag = DisposeBag()
    enum FileReadError: Error{
        case fileNotFound, unreadeable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            let disposable = Disposables.create()
            //single(.error(FileReadError.fileNotFound))
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            print(type(of: path)) // String
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadeable))
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
    
    loadText(from: "Copyright")
        .subscribe {
            switch $0{
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
    }
    .disposed(by: disposeBag)
}

func obsMaybe(){
    let disposeBag = DisposeBag()
    enum FileReadError: Error{
        case fileNotFound, unreadeable, encodingFailed
    }
    
    func loadText(from name: String) -> Maybe<String> {
        return Maybe<String>.create { maybe in
            let disposable = Disposables.create()
            //maybe(.error(FileReadError.fileNotFound))
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                maybe(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                maybe(.error(FileReadError.unreadeable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                maybe(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            maybe(.success(contents))
            maybe(.completed)
            
            return disposable
        }
    }
    
    loadText(from: "Copyright")
        .subscribe {
            switch $0 {
            case .completed:
                print("Completed obsMaybe!")
            case .error(let error):
                print(error)
            case .success(let str):
                print(str)
            }
    }
    .disposed(by: disposeBag)
}

func obsCompletable(){
    let disposeBag = DisposeBag()
    enum FileReadError: Error{
        case fileNotFound, unreadeable, encodingFailed
    }
    
    func loadText(from name: String) -> Completable {
        return Completable.create { completable in
            let disposable = Disposables.create()
            completable(.error(FileReadError.fileNotFound))
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                completable(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                completable(.error(FileReadError.unreadeable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                completable(.error(FileReadError.encodingFailed))
                return disposable
            }
            completable(.completed)
            
            return disposable
        }
    }
    
    loadText(from: "Copyright")
        .subscribe {
            switch $0 {
            case .completed:
                print("Completed obsMaybe!")
            case .error(let error):
                print(error)
            }
    }
    .disposed(by: disposeBag)
}

// End

struct Fundermental2View: View {
    @State var showAlert = false
    
    var tipAlert: Alert {
        Alert(title: Text("Tip!"), message: Text("""
            1. Traits: After running error or success, it is done! No more running code in closure.
        """), dismissButton: .default(Text("Dismiss")))
    }
    
    var navBarButton: some View {
        Button(action: {self.showAlert.toggle()}){
            Text("Tip")
        }
    }
    var body: some View {
        List{
            Button(action: {obsDefer()}){ Text("obsDefer()").foregroundColor(Color.blue)}
            Text("- Traits -")
            Button(action: {obsSingle()}){ Text("obsSingle()").foregroundColor(Color.blue)}
            Button(action: {obsMaybe()}){ Text("obsMaybe()").foregroundColor(Color.blue)}
            Button(action: {obsCompletable()}){ Text("obsCompletable()").foregroundColor(Color.blue)}
            //Button(action: {()}){ Text("()").foregroundColor(Color.blue)}
        }
        .alert(isPresented: $showAlert, content: {tipAlert})
        .navigationBarItems(trailing: navBarButton)
        .navigationBarTitle("Fundermental2View", displayMode: .inline)
    }
}

struct Fundermental2View_Previews: PreviewProvider {
    static var previews: some View {
        Fundermental2View()
    }
}
