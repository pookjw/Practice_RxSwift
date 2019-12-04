//
//  ContentView.swift
//  RxSwift_Practice
//
//  Created by pook on 12/4/19.
//  Copyright © 2019 pookjw. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: ImageView()){
                    Text("ImageView")
                }
            }
        .navigationBarTitle(Text("RxSwift"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
