//
//  DeckInspectorView.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/29/25.
//

import SwiftUI

struct DeckInspectorView : View {
    
    let remainingCards : [Card]
    let ranksInOrder : [Rank] = Rank.allCases
    
    @Environment(\.dismiss) var dismiss
    
    var allCards : [Card] {
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
    }
    
    func isInDeck(_ card : Card) -> Bool {
        remainingCards.contains { other in
            other.suit == card.suit &&
            other.rank == card.rank
        }
    }
    
    func hiLoValue(for rank : Rank) -> Int {
        switch rank {
        case .two, .three, .four, .five, .six:
            return 1
        case .seven, .eight, .nine:
            return 0
        case .ten, .jack, .queen, .king, .ace:
            return -1
        }
    }
    
    var runningCount : Int {
        allCards
            .filter { !isInDeck($0) }
            .reduce(0) { partial, card in
                partial + hiLoValue(for: card.rank)
            }
    }
    
    var decksRemainingEstimate : Double {
        max(
            0.25,
            Double(remainingCards.count) / 52.0
        )
    }
    
    var trueCount : Double {
        if decksRemainingEstimate <= 0 {
            return 0.0
        }
        
        return Double(runningCount) / decksRemainingEstimate
    }
    
    var cardsSeen : Int {
        52 - remainingCards.count
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Deck Viewer")
                .font(.headline)
                .padding(.bottom, 8.0)
            
            ForEach(Suit.allCases, id: \.self) { suit in
                HStack(spacing: 4.0) {
                    ForEach(ranksInOrder, id: \.self) { rank in
                        
                        let card = Card(
                            suit: suit,
                            rank: rank
                        )
                        
                        MiniCardView(
                            card: card,
                            dimmed: !isInDeck(card)
                        )
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4.0) {
                Text("Running count (Hi-Lo): \(runningCount)")
                Text(String(format: "True count: %.2f", trueCount))
                Text("Cards seen: \(cardsSeen)")
                Text("Cards remaining: \(remainingCards.count)")
                Text(
                    String(
                        format: "Estimated decks remaining: %.2f",
                        decksRemainingEstimate
                    )
                )
            }
            .font(.footnote)
            .padding(.top, 8.0)
            
            GeometryReader { geo in
                ZStack {
                    TheButton(
                        x: geo.size.width * 0.5,
                        y: 25.0,
                        width: 100.0,
                        height: 40.0,
                        text: "Close",
                        fontSize: 16.0,
                        color: .gray
                    ) {
                        dismiss()
                    }
                }
            }
            .frame(height: 60.0)
        }
        .padding()
    }
}

// tiny simple cards so the text is very readable
struct MiniCardView : View {
    
    let card : Card
    let dimmed : Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .stroke(
                    Color.gray.opacity(0.6),
                    lineWidth: 1.0
                )
                .background(
                    RoundedRectangle(cornerRadius: 4.0)
                        .fill(Color.white)
                )
            
            VStack(spacing: 0.0) {
                Text(card.rank.label)
                    .font(
                        .system(
                            size: 10.0,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        card.isRed ? Color.red : Color.black
                    )
                
                Text(card.suit.rawValue)
                    .font(.system(size: 10.0))
                    .foregroundStyle(
                        card.isRed ? Color.red : Color.black
                    )
            }
        }
        .frame(
            width: 26.0,
            height: 36.0
        )
        .opacity(dimmed ? 0.25 : 1.0)
        .allowsHitTesting(false)
    }
}
