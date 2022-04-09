import Foundation
import CoreData

actor CoreDataStack {
    enum Error: LocalizedError {
        case alreadyRegisteredButWrongType
        case momNamesAreEmpty
        case momdNotFound
        case momNotFound
        case modelInitFailed
        case storeContainerIsRequired
        case nothingToSave
    }

    static let shared: CoreDataStack = .init()
    private var storeContainers: [String: NSPersistentContainer] = [:]
    private var contexts: [String: NSManagedObjectContext] = [:]
    
    private init() {}
    
    func storeContainer<T: NSPersistentContainer>(for modelName: String, momNames: [String]) async throws -> T {
        if let storeContainer: NSPersistentContainer = storeContainers[modelName] {
            guard let storeContainer: T = storeContainer as? T else {
                throw Error.alreadyRegisteredButWrongType
            }
            return storeContainer
        }
        
        guard let latestMomName: String = momNames.last else {
            throw Error.momNamesAreEmpty
        }
        
        let model: NSManagedObjectModel = try model(from: modelName, momName: latestMomName)
        let storeContainer: T = .init(name: modelName, managedObjectModel: model)
        
        let _: NSPersistentStoreDescription = try await withCheckedThrowingContinuation { continuation in
            storeContainer.loadPersistentStores { description, error in
                if let error: Swift.Error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: description)
                }
            }
        }
        
        try await migrateIfNeeded()
        
        storeContainers[modelName] = storeContainer
        
        return storeContainer
    }
    
    func context(for modelName: String) throws -> NSManagedObjectContext {
        if let context: NSManagedObjectContext = contexts[modelName] {
            return context
        }
        
        guard let storeContainer: NSPersistentContainer = storeContainers[modelName] else {
            throw Error.storeContainerIsRequired
        }
        
        let context: NSManagedObjectContext = storeContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        contexts[modelName] = context
        return context
    }
    
    nonisolated func saveChanges(for modelName: String) async throws {
        let context: NSManagedObjectContext = try await context(for: modelName)
        
        guard context.hasChanges else {
            throw Error.nothingToSave
        }
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    try continuation.resume(returning: context.save())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func model(from modelName: String, momName: String) throws -> NSManagedObjectModel {
        guard let urls: [URL] = Bundle.module.urls(forResourcesWithExtension: "mom", subdirectory: "\(modelName).momd") else {
            throw Error.momdNotFound
        }
        
        guard let url: URL = urls.first(where: { $0.deletingPathExtension().lastPathComponent == momName }) else {
            throw Error.momNotFound
        }
        
        guard let model: NSManagedObjectModel = .init(contentsOf: url) else {
            throw Error.modelInitFailed
        }
        
        return model
    }
    
    private func migrateIfNeeded() async throws {
        // TODO
    }
}
