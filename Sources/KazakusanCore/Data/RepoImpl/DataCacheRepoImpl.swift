//import CoreData
//
//@globalActor actor DataCacheRepoImpl: DataCacheRepo {
//    static let shared: DataCacheRepoImpl = await .init()
//    let didChangeDataCache: AsyncStream<(Notification.Name, [String : Any]?)> = .init { c in
//        
//    }
//    
//    var fileSize: Int64 {
//        get async throws {
//            guard let url: URL = storeContainer?.persistentStoreCoordinator.persistentStores.first?.url else {
//                return 0
//            }
//            
//            return 0
//        }
//    }
//    
//    private let storeContainer: NSPersistentContainer
//    
//    private init() async {
//        self.storeContainer = try await CoreDataStack.shared.storeContainer(for: "DataCache", momNames: ["DataCache_v1"])
//    }
//    
//    func saveChanges() async throws {
//        
//    }
//    
//    func dataCache(with identity: String) async throws -> DataCache {
//        // TODO
//        return .init()
//    }
//    
//    func deleteAllCaches() async throws {
//        
//    }
//    
//    nonisolated func createDataCache() -> DataCache {
//        return .init() // TODO
//    }
//    
//    
//}
