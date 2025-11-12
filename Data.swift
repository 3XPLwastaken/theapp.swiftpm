//
//  Data.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/11/25.
//

import SwiftUI
import SwiftData

class Data : ObservableObject {
    @Published var gamesList : [
        String
    ] = [
        "Idk;GamesPlayed;0",
        "Idk;GamesPlayed;0",
        "Idk;GamesPlayed;0",
    ]
    
    @Published var moneyUp = 0
    @Published var moneyText = "+ $0"
}
