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
    
    @State var moneyText = "+ $10"
    @State var moneyColor = Color.black
    
    @State var showMoneyThing = false
    @State var showGamesPlayed = false
    
    @State var moneyInput : String = ""
    @State var gamesInput : String = ""
    
    @State var moneyCalc = 0.0
    
    func calculateWinnings() {
        moneyCalc = 0.0
        
        for i in 0..<data.gamesList.count {
            moneyCalc += Double(data.gamesList[i].split(separator: ";")[2])!
        }
        
        if (moneyCalc == 0) {
            moneyText = "WINNINGS BALANCED"
            moneyColor = Color.yellow
            return
        }
        
        moneyCalc = round(moneyCalc*100)/100
        
        if (moneyCalc > 0) {
            moneyText = "+ $\(moneyCalc)"
            moneyColor = Color.green
        } else {
            moneyText = "- $\(abs(moneyCalc))"
            moneyColor = Color.red
        }
    }
    
    var body: some View {
        ZStack {
            TheButton(
                x: (width/2.0),
                y: height - height/5,
                width: width - 25.0,
                height: height/17,
                text: "add to win loss counter",
                rotatingEnabled: false
            ) {
                showMoneyThing = true
            }
            
            Text("Hard-Set Statistics")
                .font(.custom("Arial", size: 30.0))
                .bold()
                .position(
                    x: width/2,
                    y: height/30
                )
                .monospaced()
            
            Text("win loss counter:")
                .font(.custom("Arial", size: 20.0))
                .bold()
                .offset(y: -310)
                .monospaced()
            
            Text(moneyText)
                .font(.custom("Arial", size: 20.0))
                .bold()
                .offset(y: -280)
                .monospaced()
                .foregroundStyle(moneyColor)
            
            List {
                ForEach(data.gamesList, id: \.hashValue) { str in
                    HStack {
                        Text(str.split(separator: ";")[0])
                            .bold()
                        Spacer()
                        Text(str.split(separator: ";")[1])
                            .bold()
                        Spacer()
                        Text("$\(str.split(separator: ";")[2])")
                            .bold()
                    }
                }.onDelete(perform: { offset in
                    data.gamesList.remove(atOffsets: offset)
                })
                .frame(maxWidth: .infinity, alignment: .center)
            }.frame(width: .infinity, height: height/3)
            
            /*TheButton(
                x: (width/3.0) - 25.0,
                y: height - height/5,
                width: width/2 - 25.0,
                height: height/17,
                text: "help",
            )*/
        }.alert("Enter your winnings", isPresented: $showMoneyThing) {
            TextField("Your win/loss in dollars:", text: $moneyInput)
            Button("Submit") {
                showGamesPlayed = true
            }
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("only enter a valid number or you will die")
        }
        .alert("Enter the amount of games you played", isPresented: $showGamesPlayed) {
            TextField("Your game count:", text: $gamesInput)
            Button("Submit") {
                moneyCalc = 0.0
                
                if let m = Double(moneyInput), let _ = Int(gamesInput) {
                    moneyCalc += m
                    data.gamesList.append(
                        "game #\(data.gamesList.count);\(gamesInput);\(moneyInput)"
                    )
                } else {
                    // todo: error
                }
                
                calculateWinnings()
            }
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            //Text("Please enter your name in the field below.")
        }
    }
}

#Preview {
    StatisticsView(data: .init())
}
