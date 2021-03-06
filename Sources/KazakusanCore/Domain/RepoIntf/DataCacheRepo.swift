import Foundation

protocol DataCacheRepo {
    var didChangeDataCache: AsyncThrowingStream<(Notification.Name, [AnyHashable : Any]?), Swift.Error> { get }
    
    var didDeleteAllCaches: AsyncStream<Void> { get }
    
    var fileSize: Int64 { get async throws }
    
    func saveChanges() async throws
    
    func dataCache(with identity: String) async throws -> DataCache
    
    func createDataCache() async throws -> DataCache
    
    func deleteAllCaches() async throws
}
