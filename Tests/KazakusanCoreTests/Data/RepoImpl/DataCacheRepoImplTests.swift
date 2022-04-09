import XCTest
@testable import KazakusanCore

final class DataCacheRepoImplTests: XCTestCase {
    private var dataCacheRepo: DataCacheRepo!
    
    override func setUp() async throws {
        try await super.setUp()
        dataCacheRepo = DataCacheRepoImpl.shared
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        dataCacheRepo = nil
    }
    
    func testFlow() async throws {
        let expactation: XCTestExpectation = .init()
        
        Task.detached {
            for try await _ in self.dataCacheRepo.didChangeDataCache {
                expactation.fulfill()
            }
        }
        
        let identity: String = UUID().uuidString
        let dataCount: Int = 300
        let data: Data = .init(count: dataCount)
        let dataCache: DataCache = try await dataCacheRepo.createDataCache()
        
        dataCache.identity = identity
        dataCache.data = data
        
        try await dataCacheRepo.saveChanges()
        let readDataCache: DataCache = try await dataCacheRepo.dataCache(with: identity)
        
        XCTAssertEqual(dataCount, readDataCache.data?.count ?? 0)
        wait(for: [expactation], timeout: 5.0)
    }
    
    func testDeleteAllCaches() async throws {
        let expactation: XCTestExpectation = .init()
        
        Task.detached {
            for await _ in self.dataCacheRepo.didDeleteAllCaches {
                expactation.fulfill()
            }
        }
        
        try await dataCacheRepo.deleteAllCaches()
        wait(for: [expactation], timeout: 5.0)
    }
    
    func testFileSize() async throws {
        let fileSize: Int64 = try await dataCacheRepo.fileSize
        XCTAssertGreaterThan(fileSize, 0)
    }
}
