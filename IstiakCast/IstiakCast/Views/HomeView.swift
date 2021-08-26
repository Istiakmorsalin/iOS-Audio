//
//  HomeView.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import SwiftUI


struct HomeView: View {
    
    var body: some View {
        List {
          HStack {
            Text("AvaudioEngine").onTapGesture {
                print("AvaudioEngine")
            }
            Text("AvPlayer").onTapGesture {
                print("AvPlayer")
            }
          }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}


