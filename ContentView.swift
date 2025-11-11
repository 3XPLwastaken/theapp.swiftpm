import SwiftUI

struct ContentView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @State var showingStatistics : Bool = false
    @ObservedObject var DATA = Data();
    
    var body: some View {
        NavigationStack {
            ZStack {
                TheButton(
                    x: (width/3.0) - 25.0,
                    y: height - height/5,
                    width: width/2 - 25.0,
                    height: height/17,
                    text: "settings",
                )
                
                TheButton(
                    x: (width/3*2.0 + 25.0),
                    y: height - height/5,
                    width: width/2 - 25.0,
                    height: height/17,
                    text: "help",
                )
                
                
                TheButton(
                    x: (width/2.0),
                    y: height - height/2.67,
                    width: width - 40.0,// - 25.0,
                    height: height/8,
                    text: "Train",
                    fontSize: 45.0,
                    rotatingEnabled: false,
                ) {
                    showingStatistics = true
                }
                
                TheButton(
                    x: (width/2.0),
                    y: height - height/3.7,
                    width: width - 40.0,// - 25.0,
                    height: height/17,
                    text: "Statistics",
                    rotatingEnabled: false,
                )
            }
        }
        // todo: change this system
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(data: DATA)
        }
    }
}
