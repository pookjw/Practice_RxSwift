//
//  DownlaodImageView.swift
//  Practice
//
//  Created by pook on 1/18/20.
//  Copyright © 2020 pookjw. All rights reserved.
//

import SwiftUI
import RxSwift

struct DownlaodImageView: View {
    
    @State var disposeBag = DisposeBag()
    @State var background_image: Image?
    @State var status = "Waiting..."
    @State var counter = 0
    
    func getImage(_ url: String) throws -> Image {
        let url = URL(string: url)!
        let data = try Data(contentsOf: url)
        let uiimage = UIImage(data: data)
        let image = Image(uiImage: uiimage!)
        return image
    }
    
    var navBarButton: some View {
        HStack{
            cancelButton
            clearButton
            syncButton
            asyncButton
            Text(String(self.counter))
        }
    }
    
    var syncButton: some View {
        Button(action: {
            do{
                self.status = "Downloading..."
                Thread.sleep(forTimeInterval: 2.0)
                self.background_image = try self.getImage("https://picsum.photos/1000/1600")
                self.status = "Success!"
            } catch {
                self.status = "Error!"
            }
        })
        {
            Text("Sync")
        }
    }
    
    var asyncButton: some View {
        Button(action: {
            Observable<String>.create {observer in
                //Thread.sleep(forTimeInterval: 2.0)
                observer.on(.next("https://picsum.photos/1000/1600"))
                if self.background_image != nil {
                    observer.on(.completed)
                }
                return Disposables.create { self.status = "Canceled." }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(
                onNext: { url in
                    do{
                        self.status = "Downloading..."
                        Thread.sleep(forTimeInterval: 2.0)
                        try self.background_image = self.getImage("\(url)")
                    }catch (let error){
                        self.status = "Error!"
                        self.background_image = nil
                    }
            },
                onCompleted: {
                    self.status = "Success!"
            }
            )
            .disposed(by: self.disposeBag)
        })
        {
            Text("Async")
        }
    }
    
    var clearButton: some View {
        Button(action: {
            self.counter = 0
            self.background_image = nil
            self.status = "Waiting..."
        }){
            Text("Clear")
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            self.disposeBag = DisposeBag()
        }){
            Text("Cancel")
        }
    }
    
    var body: some View {
        ScrollView{
            HStack{
                Spacer()
            }
            Text("Status: \(status)")
            if background_image != nil {
                background_image!
                    .resizable()
                    .scaledToFit()
            }
            
        }
        .navigationBarItems(trailing: navBarButton)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.counter += 1
            }
        }
    }
}

struct DownlaodImageView_Previews: PreviewProvider {
    static var previews: some View {
        DownlaodImageView()
    }
}
