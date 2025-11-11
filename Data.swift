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
        "Idk;GamesPlayed;MoneyChange",
        "Idk;GamesPlayed;MoneyChange",
        "Idk;GamesPlayed;MoneyChange",
    ]
}
