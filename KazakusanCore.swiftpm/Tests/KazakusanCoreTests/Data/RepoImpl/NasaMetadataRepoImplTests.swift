import XCTest
@testable import KazakusanCore

final class NasaMetadataRepoImplTests: XCTestCase {
    private var nasaMetadataRepo: NasaMetadataRepo!
    
    override func setUp() async throws {
        try await super.setUp()
        nasaMetadataRepo = NasaMetadataRepoImpl(nasaApi: nil)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        nasaMetadataRepo = nil
    }
    
    func testMetadata() async throws {
        let metadata: NasaMetadata = try await nasaMetadataRepo.metadata(from: "KSC-20190521-PC-MMS01-0001_RocketRanch10_3218706")
        XCTAssertNotNil(metadata.location)
    }
    
    func testCaptions() async throws {
        let metadata: NasaMetadata = try await nasaMetadataRepo.captions(from: "172_ISS-Slosh")
        XCTAssertNotNil(metadata.location)
    }
}
