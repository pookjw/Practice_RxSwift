//
//  ContentView.swift
//  Practice
//
//  Created by pook on 1/18/20.
//  Copyright © 2020 pookjw. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: DownlaodImageView()) {
                    Text("DownlaodImageView")
                }
            }
        .navigationBarTitle("Practice")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
