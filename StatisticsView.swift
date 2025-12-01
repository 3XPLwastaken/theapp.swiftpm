import SwiftUI

struct StatisticsView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @ObservedObject var data : Data
    
    @State var showingScreen : Bool = false
    
    @State var moneyText = "+ $10"
    @State var moneyColor = Color.black
    
    @State var showMoneyThing = false
    @State var showGamesPlayed = false
    
    @State var moneyInput : String = ""
    @State var gamesInput : String = ""
    
    @State var moneyCalc = 0.0
    
    @State var graphData : [Double] = [0.0]
    
    func calculateWinnings() {
        moneyCalc = 0.0
        graphData = []
        
        for gameString in data.gamesList {
            let components = gameString.split(separator: ";")
            if components.count == 3,
               let value = Double(components[2]) {
                moneyCalc += value
                graphData.append(value)
            }
        }
        
        if moneyCalc == 0 {
            moneyText = "WINNINGS BALANCED"
            moneyColor = Color.yellow
            return
        }
        
        moneyCalc = round(moneyCalc * 100) / 100
        
        if moneyCalc > 0 {
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
                x: width/2.0,
                y: height - height/5.0,
                width: width - 25.0,
                height: height/17.0,
                text: "add to win loss counter",
                fontSize: 18.0,
                color: .blue
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
            
            GraphView(
                data: $graphData
            )
            .position(
                x: width/2,
                y: height/3
            )
            
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
                }
                .onDelete { offset in
                    data.gamesList.remove(atOffsets: offset)
                    calculateWinnings()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
            .frame(width: .infinity, height: height/4.2)
            .position(
                x: width/2,
                y: height/1.557
            )
            
        }
        .alert("Enter your winnings", isPresented: $showMoneyThing) {
            TextField("Your win/loss in dollars:", text: $moneyInput)
                .keyboardType(.decimalPad)
            Button("Submit") {
                showGamesPlayed = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Use a negative sign for losses)")
        }
        .alert("Enter the amount of games you played", isPresented: $showGamesPlayed) {
            TextField("Your game count:", text: $gamesInput)
                .keyboardType(.numberPad)
            Button("Submit") {
                moneyCalc = 0.0
                
                if let _ = Double(moneyInput),
                   let _ = Int(gamesInput) {
                    
                    data.gamesList.append(
                        "\(Date.now.formatted(date: .abbreviated, time: .shortened));\(gamesInput);\(moneyInput)"
                    )
                    
                    calculateWinnings()
                    
                    moneyInput = ""
                    gamesInput = ""
                    
                } else {
                    print("Invalid input")
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            // empty
        }
        .onAppear {
            calculateWinnings()
        }
        // i love deprecated functions
        .onChange(of: data.gamesList) { _ in
            // auto-update when blackjack adds new rows
            calculateWinnings()
        }
    }
}

#Preview("StatisticsView") {
    StatisticsView(data: Data())
}
