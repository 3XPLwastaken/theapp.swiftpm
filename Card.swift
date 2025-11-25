//
//  Card.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/25/25.
//

import SwiftUI


// MARK: - Card Model

enum Suit: String, CaseIterable {
    case spades = "♠︎"
    case hearts = "♥︎"
    case diamonds = "♦︎"
    case clubs = "♣︎"
}

enum Rank: CaseIterable {
    case two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace

    var label: String {
        switch self {
        case .two:   return "2"
        case .three: return "3"
        case .four:  return "4"
        case .five:  return "5"
        case .six:   return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine:  return "9"
        case .ten:   return "10"
        case .jack:  return "J"
        case .queen: return "Q"
        case .king:  return "K"
        case .ace:   return "A"
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    let suit: Suit
    let rank: Rank

    var isRed: Bool {
        suit == .hearts || suit == .diamonds
    }
}

// MARK: - Card View

struct CardView: View {
    let card: Card
    let faceDown: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(faceDown ? Color.black.opacity(0.85) : Color.white)
                .shadow(radius: 4)

            if faceDown {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                    .padding(4)
                Text("🂠")
                    .font(.title2)
            } else {
                VStack(alignment: .leading) {
                    Text(card.rank.label)
                        .font(.headline)
                        .bold()
                        .foregroundColor(card.isRed ? .red : .black)

                    Spacer()

                    Text(card.suit.rawValue)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(card.isRed ? .red : .black)
                        //.offset(35)

                    Spacer()

                    HStack {
                        Spacer()
                        Text(card.rank.label)
                            .font(.headline)
                            .bold()
                            .rotationEffect(.degrees(180))
                            .foregroundColor(card.isRed ? .red : .black)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 70, height: 100)
    }
}

#Preview {
    CardView(card: Card(suit: .hearts, rank: .ace), faceDown: false)
}
