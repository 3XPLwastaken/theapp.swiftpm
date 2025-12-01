import SwiftUI

// struct for a collection of cards

struct Deck {
    var cards : [Card] = {
        var result : [Card] = []
        
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                result.append(
                    Card(
                        suit: suit,
                        rank: rank
                    )
                )
            }
        }
        
        return result
    }()
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func deal() -> Card? {
        if cards.isEmpty {
            return nil
        }
        
        return cards.removeLast()
    }
}

// yuck

enum GamePhase {
    case playerTurn
    case dealerTurn
    case roundOver
}

enum RoundOutcome {
    case playerBlackjack
    case dealerBlackjack
    case bothBlackjack
    case playerWin
    case dealerWin
    case push
    case playerBust
    case dealerBust
}

// the game view

struct BlackjackView : View {
    
    @ObservedObject var data : Data
    
    @State var deck = Deck()
    
    @State var playerCards : [Card] = []
    @State var dealerCards : [Card] = []
    
    @State var phase : GamePhase = .playerTurn
    @State var statusText = ""
    @State var isDealerHoleCardRevealed = false
    @State var canDouble = true
    
    @State var showDeckInspector = false
    
    // money system (per session)
    @State var balance = 0.0          // total net winnings for this blackjack session
    let baseBet = 10.0                // bet per hand
    
    // session logging
    @State var sessionGames = 0       // how many hands played this session
    @State var hasLoggedSession = false
    
    var body: some View {
        
        VStack {
            // dealer
            VStack {
                Text("Dealer")
                
                ZStack(alignment: .leading) {
                    ForEach(
                        Array(dealerCards.enumerated()),
                        id: \.element.id
                    ) { index, card in
                        
                        CardView(
                            card: card,
                            faceDown: index == 1 && !isDealerHoleCardRevealed
                        )
                        .offset(
                            x: CGFloat(index) * 18.0
                        )
                        .id(card.id)
                    }
                }
                
                Text("Dealer total: \(dealerDisplayValue)")
            }
            .padding(.top)
            
            Spacer()
            
            // deck in the middle
            if let last = deck.cards.last {
                CardView(
                    card: last,
                    faceDown: true
                )
            } else {
                Text("No cards left in deck")
            }
            
            Spacer()
            
            // player
            VStack {
                ZStack(alignment: .leading) {
                    ForEach(
                        Array(playerCards.enumerated()),
                        id: \.element.id
                    ) { index, card in
                        
                        CardView(
                            card: card,
                            faceDown: false
                        )
                        .offset(
                            x: CGFloat(index) * 18.0
                        )
                        .id(card.id)
                    }
                }
                
                Text("Your total: \(handValue(playerCards))")
            }
            
            Text(statusText)
                .padding(.top)
            
            // money info
            Text(String(format: "Session balance: $%.2f", balance))
                .font(.custom("Arial", size: 18.0))
                .monospaced()
                .padding(.top, 4.0)
            
            Text(String(format: "Bet per hand: $%.0f", baseBet))
                .font(.custom("Arial", size: 16.0))
                .monospaced()
                .padding(.bottom, 4.0)
            
            // buttons row 1 - hit / stand / double
            GeometryReader { geo in
                ZStack {
                    
                    TheButton(
                        x: geo.size.width * 0.25,
                        y: 30.0,
                        width: 90.0,
                        height: 40.0,
                        text: "Hit",
                        fontSize: 18.0,
                        color: .blue
                    ) {
                        if phase == .playerTurn {
                            hit()
                        }
                    }
                    
                    TheButton(
                        x: geo.size.width * 0.5,
                        y: 30.0,
                        width: 90.0,
                        height: 40.0,
                        text: "Stand",
                        fontSize: 18.0,
                        color: .green
                    ) {
                        if phase == .playerTurn {
                            stand()
                        }
                    }
                    
                    TheButton(
                        x: geo.size.width * 0.75,
                        y: 30.0,
                        width: 90.0,
                        height: 40.0,
                        text: "Double",
                        fontSize: 18.0,
                        color: .orange
                    ) {
                        if phase == .playerTurn && canDouble {
                            doubleDown()
                        }
                    }
                }
            }
            .frame(height: 80.0)
            
            // buttons row 2 - deck info / new round
            GeometryReader { geo in
                ZStack {
                    
                    TheButton(
                        x: geo.size.width * 0.25,
                        y: 30.0,
                        width: 110.0,
                        height: 40.0,
                        text: "Deck Info",
                        fontSize: 16.0,
                        color: .purple
                    ) {
                        showDeckInspector = true
                    }
                    
                    TheButton(
                        x: geo.size.width * 0.75,
                        y: 30.0,
                        width: 110.0,
                        height: 40.0,
                        text: "New Round",
                        fontSize: 16.0,
                        color: .red
                    ) {
                        if phase == .roundOver {
                            startNewRound()
                        }
                    }
                }
            }
            .frame(height: 80.0)
        }
        .padding()
        .onAppear {
            // new blackjack session starts here
            balance = 0.0
            sessionGames = 0
            hasLoggedSession = false
            startNewRound()
        }
        .onDisappear {
            // sheet closed -> log this whole session ONCE
            logSessionToStatsIfNeeded()
        }
        .sheet(isPresented: $showDeckInspector) {
            DeckInspectorView(
                remainingCards: deck.cards
            )
        }
    }
    
    // MARK: - Helper computed stuff
    
    var dealerDisplayValue : Int {
        if isDealerHoleCardRevealed {
            return handValue(dealerCards)
        }
        
        if let first = dealerCards.first {
            return handValue([first])
        }
        
        return 0
    }
    
    // MARK: - Game logic
    
    func startNewRound() {
        deck = Deck()
        deck.shuffle()
        
        playerCards.removeAll()
        dealerCards.removeAll()
        
        phase = .playerTurn
        statusText = "Your turn"
        isDealerHoleCardRevealed = false
        canDouble = true
        
        dealCard(to: &playerCards)
        dealCard(to: &dealerCards)
        dealCard(to: &playerCards)
        dealCard(to: &dealerCards)
        
        checkInitialBlackjack()
    }
    
    func dealCard(to hand : inout [Card]) {
        if let card = deck.deal() {
            withAnimation(
                .spring(
                    response: 0.25,
                    dampingFraction: 0.8
                )
            ) {
                hand.append(card)
            }
        }
    }
    
    func handValue(_ cards : [Card]) -> Int {
        var total = 0
        var aces = 0
        
        for card in cards {
            switch card.rank {
            case .two:   total += 2
            case .three: total += 3
            case .four:  total += 4
            case .five:  total += 5
            case .six:   total += 6
            case .seven: total += 7
            case .eight: total += 8
            case .nine:  total += 9
            case .ten,
                 .jack,
                 .queen,
                 .king:
                total += 10
            case .ace:
                aces += 1
                total += 11
            }
        }
        
        while total > 21 && aces > 0 {
            total -= 10
            aces -= 1
        }
        
        return total
    }
    
    func checkInitialBlackjack() {
        let playerTotal = handValue(playerCards)
        let dealerTotal = handValue(dealerCards)
        
        if playerTotal == 21 || dealerTotal == 21 {
            var outcome : RoundOutcome
            
            if playerTotal == 21 && dealerTotal == 21 {
                outcome = .bothBlackjack
            } else if playerTotal == 21 {
                outcome = .playerBlackjack
            } else {
                outcome = .dealerBlackjack
            }
            
            finishRound(
                outcome: outcome,
                betMultiplier: 1.0
            )
        }
    }
    
    func hit() {
        if phase != .playerTurn {
            return
        }
        
        dealCard(to: &playerCards)
        canDouble = false
        
        let total = handValue(playerCards)
        
        if total > 21 {
            finishRound(
                outcome: .playerBust,
                betMultiplier: 1.0
            )
        } else if total == 21 {
            stand()
        }
    }
    
    func stand(betMultiplier : Double = 1.0) {
        if phase != .playerTurn {
            return
        }
        
        canDouble = false
        phase = .dealerTurn
        isDealerHoleCardRevealed = true
        
        dealerPlay(betMultiplier: betMultiplier)
    }
    
    func doubleDown() {
        if phase != .playerTurn {
            return
        }
        
        if playerCards.count != 2 {
            return
        }
        
        canDouble = false
        
        dealCard(to: &playerCards)
        
        let total = handValue(playerCards)
        
        if total > 21 {
            finishRound(
                outcome: .playerBust,
                betMultiplier: 2.0
            )
        } else {
            stand(betMultiplier: 2.0)
        }
    }
    
    func dealerPlay(betMultiplier : Double = 1.0) {
        while handValue(dealerCards) < 17 {
            dealCard(to: &dealerCards)
        }
        
        let playerTotal = handValue(playerCards)
        let dealerTotal = handValue(dealerCards)
        
        let outcome : RoundOutcome
        
        if dealerTotal > 21 {
            outcome = .dealerBust
        } else if dealerTotal > playerTotal {
            outcome = .dealerWin
        } else if dealerTotal < playerTotal {
            outcome = .playerWin
        } else {
            outcome = .push
        }
        
        finishRound(
            outcome: outcome,
            betMultiplier: betMultiplier
        )
    }
    
    
    func finishRound(outcome : RoundOutcome, betMultiplier : Double) {
        let bet = baseBet * betMultiplier
        var delta = 0.0
        
        switch outcome {
        case .playerBlackjack:
            statusText = "Blackjack! You win"
            delta = bet * 1.5
        case .dealerBlackjack:
            statusText = "Dealer has blackjack – you lose"
            delta = -bet
        case .bothBlackjack:
            statusText = "Both blackjack – push"
            delta = 0.0
        case .playerWin:
            statusText = "You win"
            delta = bet
        case .dealerWin:
            statusText = "Dealer wins"
            delta = -bet
        case .push:
            statusText = "Push"
            delta = 0.0
        case .playerBust:
            statusText = "You bust – dealer wins"
            delta = -bet
        case .dealerBust:
            statusText = "Dealer busts – you win"
            delta = bet
        }
        
        phase = .roundOver
        isDealerHoleCardRevealed = true
        
        // update session only (no stats write yet)
        balance += delta
        sessionGames += 1
    }
    
    // MARK: - Session logging
    
    func logSessionToStatsIfNeeded() {
        if hasLoggedSession {
            return
        }
        
        // nothing to log if you didn't finish any rounds
        if sessionGames <= 0 {
            return
        }
        
        let dateString = Date.now.formatted(
            date: .abbreviated,
            time: .shortened
        )
        
        let deltaString = String(
            format: "%.2f",
            balance
        )
        
        let gamesString = String(sessionGames)
        
        // one row = one blackjack session
        // "date;gamesPlayed;netMoney"
        data.gamesList.append(
            "\(dateString);\(gamesString);\(deltaString)"
        )
        
        hasLoggedSession = true
    }
}

#Preview {
    BlackjackView(data: Data())
}
