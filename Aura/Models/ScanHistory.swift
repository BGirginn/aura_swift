//
//  ScanHistory.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import CoreData

/// Core Data entity for persisting scan history
@objc(ScanHistory)
public class ScanHistory: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var primaryColorId: String
    @NSManaged public var secondaryColorId: String?
    @NSManaged public var tertiaryColorId: String?
    @NSManaged public var dominancePercentages: Data // JSON encoded [Double]
    @NSManaged public var countryCode: String
    @NSManaged public var imageData: Data?
    @NSManaged public var isFavorite: Bool
}

// MARK: - Core Data Configuration
extension ScanHistory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScanHistory> {
        return NSFetchRequest<ScanHistory>(entityName: "ScanHistory")
    }
    
    /// Fetch all scan history ordered by timestamp descending
    static func fetchAllRequest() -> NSFetchRequest<ScanHistory> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScanHistory.timestamp, ascending: false)]
        return request
    }
    
    /// Fetch favorite scans only
    static func fetchFavoritesRequest() -> NSFetchRequest<ScanHistory> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScanHistory.timestamp, ascending: false)]
        return request
    }
}

// MARK: - Conversion Methods
extension ScanHistory {
    /// Convert ScanHistory entity to AuraResult model
    func toAuraResult() -> AuraResult? {
        guard let primaryColor = AuraColor.allColors.first(where: { $0.id == primaryColorId }) else {
            return nil
        }
        
        let secondaryColor = secondaryColorId != nil ? AuraColor.allColors.first(where: { $0.id == secondaryColorId }) : nil
        let tertiaryColor = tertiaryColorId != nil ? AuraColor.allColors.first(where: { $0.id == tertiaryColorId }) : nil
        
        var percentages: [Double] = []
        if let decoded = try? JSONDecoder().decode([Double].self, from: dominancePercentages) {
            percentages = decoded
        }
        
        return AuraResult(
            id: id,
            timestamp: timestamp,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            dominancePercentages: percentages,
            countryCode: countryCode,
            imageData: imageData
        )
    }
    
    /// Create ScanHistory from AuraResult
    static func create(from result: AuraResult, context: NSManagedObjectContext) -> ScanHistory {
        let history = ScanHistory(context: context)
        history.id = result.id
        history.timestamp = result.timestamp
        history.primaryColorId = result.primaryColor.id
        history.secondaryColorId = result.secondaryColor?.id
        history.tertiaryColorId = result.tertiaryColor?.id
        history.dominancePercentages = (try? JSONEncoder().encode(result.dominancePercentages)) ?? Data()
        history.countryCode = result.countryCode
        history.imageData = result.imageData
        history.isFavorite = false
        return history
    }
}

// MARK: - Identifiable Conformance
extension ScanHistory: Identifiable {
    public var objectID: NSManagedObjectID {
        return self.objectID
    }
}

