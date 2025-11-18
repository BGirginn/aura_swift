//
//  DataManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import CoreData

/// Manager for Core Data operations
class DataManager {
    
    static let shared = DataManager()
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AuraDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Save an aura result to history
    func saveAuraResult(_ result: AuraResult) throws {
        let context = viewContext
        _ = ScanHistory.create(from: result, context: context)
        try context.save()
    }
    
    /// Fetch all scan history
    func fetchAllHistory() throws -> [AuraResult] {
        let context = viewContext
        let request = ScanHistory.fetchAllRequest()
        let histories = try context.fetch(request)
        return histories.compactMap { $0.toAuraResult() }
    }
    
    /// Fetch favorite scans
    func fetchFavorites() throws -> [AuraResult] {
        let context = viewContext
        let request = ScanHistory.fetchFavoritesRequest()
        let histories = try context.fetch(request)
        return histories.compactMap { $0.toAuraResult() }
    }
    
    /// Delete a scan from history
    func deleteHistory(_ result: AuraResult) throws {
        let context = viewContext
        let request = ScanHistory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", result.id as CVarArg)
        
        if let history = try context.fetch(request).first {
            context.delete(history)
            try context.save()
        }
    }
    
    /// Toggle favorite status
    func toggleFavorite(_ result: AuraResult) throws {
        let context = viewContext
        let request = ScanHistory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", result.id as CVarArg)
        
        if let history = try context.fetch(request).first {
            history.isFavorite.toggle()
            try context.save()
        }
    }
    
    /// Delete all history
    func deleteAllHistory() throws {
        let context = viewContext
        let request = ScanHistory.fetchAllRequest()
        let histories = try context.fetch(request)
        
        for history in histories {
            context.delete(history)
        }
        
        try context.save()
    }
}

