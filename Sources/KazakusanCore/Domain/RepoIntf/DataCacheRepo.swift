import Foundation

protocol DataCacheRepo {
    var didChangeDataCache: AsyncStream<(Notification.Name, [String: Any]?)> { get }
    
    var fileSize: Int64 { get async throws }
    
    func saveChanges() async throws
    
    func dataCache(with identity: String) async throws -> DataCache
    
    func deleteAllCaches() async throws
    
    func createDataCache() -> DataCache
}
