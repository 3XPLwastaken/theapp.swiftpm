//
//  Data.swift
//  theapp
//
//  Created by DANIEL ARGHAVANI BADRABAD on 11/11/25.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData model that actually lives on disk

@Model
final class SavedStatistics {
    var gamesList : [String]
    var moneyUp   : Int
    var moneyText : String

    init(
        gamesList : [String] = [],
        moneyUp   : Int      = 0,
        moneyText : String   = "+ $0"
    ) {
        self.gamesList = gamesList
        self.moneyUp   = moneyUp
        self.moneyText = moneyText
    }
}

// MARK: - your Data class, now backed by SwiftData

@MainActor
class Data : ObservableObject {
    
    @Published var gamesList : [String] = [] {
        didSet { persistIfNeeded() }
    }
    
    @Published var moneyUp = 0 {
        didSet { persistIfNeeded() }
    }
    
    @Published var moneyText = "+ $0" {
        didSet { persistIfNeeded() }
    }
    
    // one shared SwiftData container for this type
    private static let modelContainer : ModelContainer = {
        do {
            let container = try ModelContainer(for: SavedStatistics.self)
            container.mainContext.autosaveEnabled = true
            return container
        } catch {
            fatalError("failed to create SavedStatistics container: \(error)")
        }
    }()
    
    private let context : ModelContext
    private var saved   : SavedStatistics
    private var isLoading = true
    
    init() {
        context = Data.modelContainer.mainContext
        
        let descriptor = FetchDescriptor<SavedStatistics>()
        
        if let existing = (try? context.fetch(descriptor))?.first {
            saved = existing
        } else {
            let fresh = SavedStatistics()
            context.insert(fresh)
            saved = fresh
            do {
                try context.save()
            } catch {
                print("initial stats save failed: \(error)")
            }
        }
        
        // pull values from SwiftData into your @Published vars
        gamesList = saved.gamesList
        moneyUp   = saved.moneyUp
        moneyText = saved.moneyText
        
        isLoading = false
    }
    
    // MARK: - persistence
    
    private func persistIfNeeded() {
        if isLoading {
            return
        }
        
        saved.gamesList = gamesList
        saved.moneyUp   = moneyUp
        saved.moneyText = moneyText
        
        do {
            try context.save()
        } catch {
            print("failed to save stats: \(error)")
        }
    }
}
