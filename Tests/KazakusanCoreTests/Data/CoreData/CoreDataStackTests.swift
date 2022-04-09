import XCTest
import CoreData
@testable import KazakusanCore

final class CoreDataStackTests: XCTestCase {
    private var coreDataStack: CoreDataStack!
    
    override func setUp() async throws {
        try await super.setUp()
        coreDataStack = .shared
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        coreDataStack = nil
    }
    
    func testDataCacheStoreContainer() async throws {
        let _: NSPersistentContainer = try await coreDataStack.storeContainer(for: "DataCache", momNames: ["DataCache_v1"])
    }
}
