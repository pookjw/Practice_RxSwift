//
//  ImageView.swift
//  RxSwift_Practice
//
//  Created by pook on 12/4/19.
//  Copyright © 2019 pookjw. All rights reserved.
//

import SwiftUI
import RxSwift

struct ImageView: View {
    @State var disposable: Disposable?
    
    @State var status = "Awaiting..."
    @State var background: Image?
    @State var counter: Int = 0
    
    var navigationBarButton: some View {
        HStack{
            Button(action: {
                if self.disposable != nil{
                    self.disposable?.dispose()
                    self.status = "Cancelled!"
                }
            }){
                Image(systemName: "pause.fill")
            }
            Button(action: {self.downloadImage()}){
                Image(systemName: "play.fill")
            }
        }
    }
    
    var body: some View {
        VStack{
            Text(String(self.counter))
            Text(status)
            background?
                .resizable()
                .scaledToFit()
        }
        .navigationBarTitle("RxTest", displayMode: .inline)
        .navigationBarItems(trailing: navigationBarButton)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.counter += 1
            }
        }
        
    }
    
    func downloadImage(){
        self.status = "Downloading..."
        self.disposable =  Observable.just("https://picsum.photos/2560/1440/?random")
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { try Data(contentsOf: $0!) }
            .map{ UIImage(data: $0) }
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.background = Image(uiImage: $0!)
            },
                       onCompleted: {
                        self.status = "Downloaded!"
            }/*,
                 onDisposed: {
                 //
                 }*/
        )
        
        /*
         guard let url = URL(string: "https://picsum.photos/1280/720/?random") else {return nil}
         guard let data = try? Data(contentsOf: url) else {return nil}
         let image = UIImage(data: data)
         
         return image
         */
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
