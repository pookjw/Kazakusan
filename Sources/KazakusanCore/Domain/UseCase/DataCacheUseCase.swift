import Foundation

public protocol DataCacheUseCase {
    var didChangeDataCache: AsyncThrowingStream<Void, Swift.Error> { get }
    
    var didDeleteAllCaches: AsyncStream<Void> { get }
    
    var fileSize: Int64 { get async throws }
    
    func dataCache(with identity: String) async throws -> DataCache
    
    @discardableResult func createDataCache(identity: String, data: Data) async throws -> DataCache
    
    func deleteAllCaches() async throws
}
