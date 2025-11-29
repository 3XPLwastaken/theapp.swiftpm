//
//  Card.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/25/25.
//

import SwiftUI

// MARK: - Card Model

enum Suit : String, CaseIterable {
    case spades    = "♠︎"
    case hearts    = "♥︎"
    case diamonds  = "♦︎"
    case clubs     = "♣︎"
}

enum Rank : CaseIterable {
    case two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace

    var label : String {
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

struct Card : Identifiable {
    let id = UUID()
    let suit : Suit
    let rank : Rank

    var isRed : Bool {
        suit == .hearts || suit == .diamonds
    }
}

// MARK: - Card View

struct CardView : View {
    
    let card : Card
    let faceDown : Bool
    var requestTopZIndex : (() -> Double)? = nil
    
    @State var dragOffset = CGSize.zero
    @State var zPosition = 0.0
    @State var hasBroughtToFront = false
    
    @GestureState var isPressed = false
    
    @State var hasAppeared = false
    @State var flipRotationY = 90.0
    
    var body: some View {
        
        let dragGesture = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }
            .onChanged { value in
                
                if !hasBroughtToFront {
                    setRenderingOrder()
                    hasBroughtToFront = true
                }
                
                dragOffset = limitedOffset(
                    from: value.translation,
                    maxDistance: 25
                )
            }
            .onEnded { _ in
                withAnimation(
                    .spring(
                        response: 0.15,
                        dampingFraction: 0.8
                    )
                ) {
                    dragOffset = .zero
                }
                
                hasBroughtToFront = false
            }
        
        ZStack {
            RoundedRectangle(cornerRadius: 12.0)
                .fill(
                    faceDown
                    ? Color.black.opacity(0.85)
                    : Color.white
                )
                .shadow(radius: 4.0)
            
            if faceDown {
                RoundedRectangle(cornerRadius: 8.0)
                    .strokeBorder(
                        Color.white.opacity(0.6),
                        lineWidth: 2.0
                    )
                    .padding(4.0)
                
                Text("🂠")
                    .font(.title2)
            } else {
                VStack(alignment: .leading) {
                    Text(card.rank.label)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(
                            card.isRed ? Color.red : Color.black
                        )
                    
                    Spacer()
                    
                    Text(card.suit.rawValue)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(
                            card.isRed ? Color.red : Color.black
                        )
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text(card.rank.label)
                            .font(.headline)
                            .bold()
                            .rotationEffect(.degrees(180.0))
                            .foregroundStyle(
                                card.isRed ? Color.red : Color.black
                            )
                    }
                }
                .padding(8.0)
            }
        }
        .frame(
            width: 70.0,
            height: 100.0
        )
        .scaleEffect(
            (hasAppeared ? 1.0 : 0.85) *
            (isPressed ? 1.18 : 1.0)
        )
        .opacity(hasAppeared ? 1.0 : 0.0)
        .offset(dragOffset)
        .rotation3DEffect(
            .degrees(flipRotationY),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .zIndex(zPosition)
        .animation(
            .spring(
                response: 0.18,
                dampingFraction: 0.8
            ),
            value: isPressed
        )
        .animation(
            .spring(
                response: 0.18,
                dampingFraction: 0.8
            ),
            value: dragOffset
        )
        .animation(
            .easeOut(duration: 0.18),
            value: hasAppeared
        )
        .animation(
            .spring(
                response: 0.35,
                dampingFraction: 0.75
            ),
            value: flipRotationY
        )
        .gesture(dragGesture)
        .onAppear {
            runSummonAnimation()
        }
    }
    
    // keeps the card close to its original position but still pointing towards your finger
    func limitedOffset(from translation : CGSize, maxDistance : CGFloat) -> CGSize {
        let dx = translation.width
        let dy = translation.height
        
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance <= 0 {
            return .zero
        }
        
        let clamped = min(distance, maxDistance)
        let scale = clamped / distance
        
        return CGSize(
            width: dx * scale,
            height: dy * scale
        )
    }
    
    func runSummonAnimation() {
        hasAppeared = false
        flipRotationY = 90.0
        
        withAnimation(.easeOut(duration: 0.18)) {
            hasAppeared = true
        }
        
        withAnimation(
            .spring(
                response: 0.35,
                dampingFraction: 0.75
            ).delay(0.03)
        ) {
            flipRotationY = 0.0
        }
    }
    
    func setRenderingOrder() {
        if let next = requestTopZIndex?() {
            zPosition = next
        } else {
            zPosition += 1.0
        }
    }
}

#Preview {
    CardView(
        card: Card(
            suit: .hearts,
            rank: .ace
        ),
        faceDown: false
    )
}

