//
//  SwiftUIView.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/7/25.
//

import SwiftUI

struct GameView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @State var showingScreen : Bool = false
    
    var body: some View {
        ZStack {
            TheButton(
                x: (width/2.0),
                y: height - height/5,
                width: width - 25.0,
                height: height/17,
                text: "go to win/loss counter",
                rotatingEnabled: false
            )
            
            Text("Hard-Set Statistics")
                .font(.custom("Arial", size: 30.0))
                .bold()
                .position(
                    x: width/2,
                    y: height/30
                )
                .monospaced()
            
            /*TheButton(
                x: (width/3.0) - 25.0,
                y: height - height/5,
                width: width/2 - 25.0,
                height: height/17,
                text: "help",
            )*/
        }
        
    }
}

#Preview {
    GameView()
}
