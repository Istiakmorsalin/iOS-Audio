//
//  HomeView.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import SwiftUI


struct HomeView: View {
    
    var body: some View {
        NavigationView {
          VStack {
            NavigationLink(
                destination: PlayerView(),
                label: {
                    Text("AvAudioEngine")
                })
            Spacer()
            NavigationLink(
                destination: HomeViewScene(),
                label: {
                    Text("AvPlayer")
                })
        
          }.frame(width: 400, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
          .navigationBarTitle("IstiakCast")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


