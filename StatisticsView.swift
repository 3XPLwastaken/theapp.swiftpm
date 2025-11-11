//
//  SwiftUIView.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/7/25.
//

import SwiftUI

struct StatisticsView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @StateObject var data : Data
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
            
            List {
                ForEach(data.gamesList, id: \.hashValue) { str in
                    HStack {
                        Text(str.split(separator: ";")[0])
                            .bold()
                        Spacer()
                        Text(str.split(separator: ";")[1])
                            .bold()
                        Spacer()
                        Text(str.split(separator: ";")[2])
                            .bold()
                    }
                }.onDelete(perform: { offset in
                    data.gamesList.remove(atOffsets: offset)
                })
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
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
    StatisticsView(data: .init())
}
