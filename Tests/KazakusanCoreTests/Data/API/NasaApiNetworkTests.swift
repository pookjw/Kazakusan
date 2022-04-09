import XCTest
@testable import KazakusanCore

final class NasaApiNetworkTests: XCTestCase {
    private var nasaApi: NasaApi!
    
    override func setUp() async throws {
        try await super.setUp()
        nasaApi = NasaApiNetwork()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        nasaApi = nil
    }
    
    func testSearch() async throws {
        async let asset: NasaAsset = nasaApi.search(q: "Mars",
                                                    center: nil,
                                                    description: nil,
                                                    description508: nil,
                                                    keywords: nil,
                                                    location: nil,
                                                    mediaType: nil,
                                                    nasaId: nil,
                                                    page: nil,
                                                    photographer: nil,
                                                    secondaryCreator: nil,
                                                    title: nil,
                                                    yearStart: nil,
                                                    yearEnd: nil)
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testAssetOrderByRecent() async throws {
        async let asset: NasaAsset = nasaApi.asset(by: "recent")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testAssetOrderByPopular() async throws {
        async let asset: NasaAsset = nasaApi.asset(by: "popular")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testDeprecatedAssetOrderByRecent() async throws {
        async let asset: NasaAsset = nasaApi._asset(by: "recent")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testDeprecatedAssetOrderByPopular() async throws {
        async let asset: NasaAsset = nasaApi._asset(by: "popular")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testAsset() async throws {
        async let asset: NasaAsset = nasaApi.asset(from: "KSC-20190521-PC-MMS01-0001_RocketRanch10_3218706")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testMetaData() async throws {
        let metadata: NasaMetadata = try await nasaApi.metadata(from: "as11-40-5874")
        XCTAssertNotNil(metadata.location)
    }
    
    func testCaptions() async throws {
        let metadata: NasaMetadata = try await nasaApi.captions(from: "172_ISS-Slosh")
        XCTAssertNotNil(metadata.location)
    }
}
