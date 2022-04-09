import XCTest
@testable import KazakusanCore

final class DataCacheUseCaseImplTests: XCTestCase {
    private var dataCacheUseCase: DataCacheUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        dataCacheUseCase = DataCacheUseCaseImpl(dataCacheRepo: nil)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        dataCacheUseCase = nil
    }
    
    func testFlow() async throws {
        let expactation: XCTestExpectation = .init()
        
        Task.detached {
            for try await _ in self.dataCacheUseCase.didChangeDataCache {
                expactation.fulfill()
            }
        }
        
        let identity: String = UUID().uuidString
        let dataCount: Int = 300
        let data: Data = .init(count: dataCount)
        let _: DataCache = try await dataCacheUseCase.createDataCache(identity: identity, data: data)
        let readDataCache: DataCache = try await dataCacheUseCase.dataCache(with: identity)
        
        XCTAssertEqual(dataCount, readDataCache.data?.count ?? 0)
        wait(for: [expactation], timeout: 5.0)
    }
    
    func testDeleteAllCaches() async throws {
        let expactation: XCTestExpectation = .init()
        
        Task.detached {
            for await _ in self.dataCacheUseCase.didDeleteAllCaches {
                expactation.fulfill()
            }
        }
        
        try await dataCacheUseCase.deleteAllCaches()
        wait(for: [expactation], timeout: .infinity)
    }
    
    func testFileSize() async throws {
        let fileSize: Int64 = try await dataCacheUseCase.fileSize
        XCTAssertGreaterThan(fileSize, 0)
    }
}
