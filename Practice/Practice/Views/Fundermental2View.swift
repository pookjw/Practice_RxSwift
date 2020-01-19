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

// End

struct Fundermental2View: View {
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
            Button(action: {obsDefer()}){ Text("obsDefer()").foregroundColor(Color.blue)}
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
