//
//  SwiftUIView.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 10/31/25.
//

import SwiftUI

@MainActor
final class GlobalState: ObservableObject {
    static let shared = GlobalState()
    @Published var isActive = false
}

struct TheButton: View {
    @ObservedObject private var global = GlobalState.shared
    
    var x = 200.0
    var y = 200.0
    
    var width = 100.0
    var height = 50.0
    
    @State var tapAngle = Angle.degrees(
        0
    )
    
    var text = "josh"
    @State var zIndex = 10.0
    @State var oldzIndex = -1.0
    @State var debounce = false
    
    var fontSize = 25.0
    @State var color = Color.blue
    var borderColor = Color.blue.opacity(0.2)
    
    @State var isAnimationPlaying = false
    var rotatingEnabled = true
    
    var action : () -> Void = {}
    
    //TODO: make it tilt where the mouse is (if i move my mouse up, it rotates up)
    
    //var grayVersion = color.mix(with: .gray, by: 0.8)
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 20.0)
            .frame(
                width: width,
                height: height
            )
        //
            //.rotation3DEffect(isAnimationPlaying ? tapAngle : Angle.zero
           //                   , axis: (x: 10, y: 180, z: 30))
            .rotationEffect((isAnimationPlaying && rotatingEnabled) ? tapAngle : Angle.zero)
            .scaleEffect(isAnimationPlaying ? 1.2 : 1.0)
            //.rotation3DEffect(.degrees(30), axis: (x: 0.0, y: 0, z: 0))
            .position(
                x: x,
                y: y
            )
            .foregroundStyle((global.isActive && !isAnimationPlaying) ? color.mix(with: .gray.opacity(0.5), by: 0.5) : color)
            .overlay {
                Text(text)
                    .font(
                        .custom("Arial", size: fontSize)
                    )
                    .scaleEffect(isAnimationPlaying ? 1.2 : 1.0)
                    //.rotation3DEffect(isAnimationPlaying ? tapAngle : Angle.zero
                    //                 , axis: (x: 10, y: 180, z: 30))
                    .rotationEffect((isAnimationPlaying && rotatingEnabled) ? tapAngle : Angle.zero)
                    .frame(width: width, height: height)
                    .foregroundStyle(.white)
                    .background(color.opacity(0.0))
                    .position(x:x, y:y)
                
                RoundedRectangle(cornerRadius: 20.0)
                    .stroke(borderColor, lineWidth: isAnimationPlaying ? 5 : 0)
                    .frame(
                        width: width,
                        height: height
                    )
                    .rotationEffect((isAnimationPlaying && rotatingEnabled) ? tapAngle : Angle.zero)
                    .scaleEffect(isAnimationPlaying ? 1.2 : 1.0)
                    .position(x: x, y: y)
                    
                //.stroke(borderColor, lineWidth: 3)
                
            }
            
            .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { change in
                            // on touch
                            //change.location
                            
                            if !debounce {
                                oldzIndex = zIndex
                                zIndex = 15.0
                                debounce = true
                                
                                tapAngle = Angle.degrees(
                                    x > (UIScreen.main.bounds.width/2) ? 2 : -2
                                )
                            }
                            
                            withAnimation(.easeIn(duration: 0.05)) {
                                isAnimationPlaying = true
                            }
                            
                            withAnimation(.easeIn(duration: 0.15)) {
                                global.isActive = true
                            }
                        }
                        .onEnded { _ in
                            // on touch ended
                            
                            //print(oldzIndex)
                            zIndex = oldzIndex
                            debounce = false
                            
                            withAnimation(.easeOut(duration: 0.15)) {
                                isAnimationPlaying = false
                                global.isActive = false
                            }
                            
                            // run the code we pass fr
                            action()
                        }
                )
        
            .zIndex(zIndex)
            
        
            
            
            
    }
}

#Preview {
    TheButton()
}
