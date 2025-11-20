import SwiftUI


struct StatisticsView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    // 2. This is the object holding your list of strings (e.g., "game #1;5;10")
    @State var data : Data
    
    @State var showingScreen : Bool = false
    
    @State var moneyText = "+ $10"
    @State var moneyColor = Color.black
    
    @State var showMoneyThing = false
    @State var showGamesPlayed = false
    
    @State var moneyInput : String = ""
    @State var gamesInput : String = ""
    
    @State var moneyCalc = 0.0
    
    // 3. This is the new array just for the graph's doubles (e.g., [10.0, -5.0])
    @State var graphData : [Double] = [0.0]
    
    // 4. Fixed this function
    func calculateWinnings() {
        moneyCalc = 0.0
        graphData = [] // Clear the graph's data array
        
        // Loop over the game strings in the 'data' object
        for gameString in data.gamesList {
            // Safely get the third part (the money)
            let components = gameString.split(separator: ";")
            if components.count == 3, let value = Double(components[2]) {
                moneyCalc += value
                graphData.append(value) // Add the value to the graph's array
            }
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
            // 5. Replaced missing 'TheButton' with a standard Button
            Button(action: {
                showMoneyThing = true
            }) {
                Text("add to win loss counter")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: width - 25.0, height: height/17)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            
            .position(
                x: (width/2.0),
                y: height - height/5
            )
            
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
                data: $graphData // array of doubles
            ).position(
                x: width/2,
                y: height/3
            )
            
            // This List code was correct, as it uses 'data.gamesList'
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
                    calculateWinnings() // Recalculate when one is deleted
                })
                .frame(maxWidth: .infinity, alignment: .center)
            }.frame(width: .infinity, height: height/4.2)
                .position(x: width/2, y: height/1.557)
            
            
        }.alert("Enter your winnings", isPresented: $showMoneyThing) {
            TextField("Your win/loss in dollars:", text: $moneyInput)
                .keyboardType(.decimalPad) // Good to set keyboard type
            Button("Submit") {
                showGamesPlayed = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Use a negative sign for losses (e.g., -10)")
        }
        .alert("Enter the amount of games you played", isPresented: $showGamesPlayed) {
            TextField("Your game count:", text: $gamesInput)
                .keyboardType(.numberPad) // Good to set keyboard type
            Button("Submit") {
                moneyCalc = 0.0
                
                // Make sure inputs are valid
                if let _ = Double(moneyInput), let _ = Int(gamesInput) {
                    /*data.gamesList.append(
                        "game #\(data.gamesList.count);\(gamesInput);\(moneyInput)"
                    )*/
                    
                    data.gamesList.append(
                        "\(Date.now.formatted(date: .abbreviated, time: .shortened));\(gamesInput);\(moneyInput)"
                    )
                    
                    // Now that data is updated, recalculate
                    calculateWinnings()
                    
                    // Clear inputs for next time
                    moneyInput = ""
                    gamesInput = ""
                    
                } else {
                    // todo: error
                    print("Invalid input")
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            //Text("Please enter your name in the field below.")
        }
        .onAppear {
            // Calculate winnings when the view first appears
            calculateWinnings()
        }
    }
}

#Preview("StatisticsView") {
    // 7. The preview now works by creating a 'Data' object instance.
    StatisticsView(data: Data())
}
