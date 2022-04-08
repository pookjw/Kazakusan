import XCTest
@testable import KazakusanCore

final class NasaAssetRepoImplTests: XCTestCase {
    private var nasaAssetRepo: NasaAssetRepo!
    
    override func setUp() async throws {
        try await super.setUp()
        nasaAssetRepo = NasaAssetRepoImpl(nasaApi: nil)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        nasaAssetRepo = nil
    }
    
    func testSearch() async throws {
        async let asset: NasaAsset = nasaAssetRepo.search(text: "Mars",
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
        async let asset: NasaAsset = nasaAssetRepo.recent()
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testAssetOrderByPopular() async throws {
        async let asset: NasaAsset = nasaAssetRepo.popular()
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testAsset() async throws {
        async let asset: NasaAsset = nasaAssetRepo.asset(from: "KSC-20190521-PC-MMS01-0001_RocketRanch10_3218706")
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
}
