import Foundation
import CoreData

actor CoreDataStack {
    enum Error: LocalizedError {
        case alreadyRegisteredButWrongType
        case momNamesAreEmpty
        case momdNotFound
        case momNotFound
        case modelInitFailed
    }

    static let shared: CoreDataStack = .init()
    private var storeContainers: [String: NSPersistentContainer] = [:]
    
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
        let storeContainer: T = try await storeContainer(from: modelName, model: model)
        
        try await migrateIfNeeded()
        
        storeContainers[modelName] = storeContainer
        
        return storeContainer
    }
    
    private func model(from modelName: String, momName: String) throws -> NSManagedObjectModel {
        guard let urls: [URL] = Bundle(for: type(of: self)).urls(forResourcesWithExtension: "mom", subdirectory: "\(modelName).momd") else {
            throw Error.momdNotFound
        }
        
        print(type(of: self))
        print(Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: nil))
        
        guard let url: URL = urls.first(where: { $0.deletingPathExtension().lastPathComponent == momName }) else {
            throw Error.momNotFound
        }
        
        guard let model: NSManagedObjectModel = .init(contentsOf: url) else {
            throw Error.modelInitFailed
        }
        
        return model
    }
    
    private func storeContainer<T: NSPersistentContainer>(from modelName: String, model: NSManagedObjectModel) async throws -> T {
        let container: T = .init(name: modelName, managedObjectModel: model)
        
        let _: NSPersistentStoreDescription = try await withCheckedThrowingContinuation { continuation in
            container.loadPersistentStores { description, error in
                if let error: Swift.Error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: description)
                }
            }
        }
        
        return container
    }
    
    private func migrateIfNeeded() async throws {
        // TODO
    }
}
