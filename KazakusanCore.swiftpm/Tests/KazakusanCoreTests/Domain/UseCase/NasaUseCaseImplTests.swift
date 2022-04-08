import XCTest
@testable import KazakusanCore

final class NasaUseCaseImplTests: XCTestCase {
    private var nasaUseCase: NasaUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        nasaUseCase = NasaUseCaseImpl(nasaAssetRepo: nil, nasaMetadataRepo: nil)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        nasaUseCase = nil
    }
    
    func testSearch() async throws {
        async let asset: NasaAsset = nasaUseCase.search(text: "Mars",
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
    
    func testPrevious() async throws {
        let asset: NasaAsset = try await nasaUseCase.search(text: "Mars",
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
        
        let nextAsset: NasaAsset = try await nasaUseCase.next(for: asset)
        let previousAsset: NasaAsset = try await nasaUseCase.previous(for: nextAsset)
        
        XCTAssertEqual(asset.collection?.items, previousAsset.collection?.items)
    }
    
    func testNext() async throws {
        let asset: NasaAsset = try await nasaUseCase.search(text: "Mars",
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
        
        async let nextAsset: NasaAsset = nasaUseCase.next(for: asset)
        let count: Int = try await nextAsset.collection?.items?.count ?? 0
        
        XCTAssertGreaterThan(count, 0)
    }
    
    func testRecent() async throws {
        async let asset: NasaAsset = nasaUseCase.recent()
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testPopular() async throws {
        async let asset: NasaAsset = nasaUseCase.popular()
        let count: Int = try await asset.collection?.items?.count ?? 0
        XCTAssertGreaterThan(count, 0)
    }
    
    func testMetaData() async throws {
        async let asset: NasaAsset = nasaUseCase.search(text: nil,
                                                        center: nil,
                                                        description: nil,
                                                        description508: nil,
                                                        keywords: nil,
                                                        location: nil,
                                                        mediaType: nil,
                                                        nasaId: "Launch-Sound_Delta-2-Launch",
                                                        page: nil,
                                                        photographer: nil,
                                                        secondaryCreator: nil,
                                                        title: nil,
                                                        yearStart: nil,
                                                        yearEnd: nil)
        
        guard let data: NasaAsset.Item.Data = try await asset.collection?.items?.first?.data?.first else {
            XCTFail("Cannot find data.")
            return
        }
        
        let metadata: [String: Any] = try await nasaUseCase.metadata(for: data)
        XCTAssertGreaterThan(metadata.count, 0)
    }
    
    func testCaptions() async throws {
        async let asset: NasaAsset = nasaUseCase.search(text: nil,
                                                        center: nil,
                                                        description: nil,
                                                        description508: nil,
                                                        keywords: nil,
                                                        location: nil,
                                                        mediaType: nil,
                                                        nasaId: "172_ISS-Slosh",
                                                        page: nil,
                                                        photographer: nil,
                                                        secondaryCreator: nil,
                                                        title: nil,
                                                        yearStart: nil,
                                                        yearEnd: nil)
        
        guard let data: NasaAsset.Item.Data = try await asset.collection?.items?.first?.data?.first else {
            XCTFail("Cannot find data.")
            return
        }
        
        let caption: Data = try await nasaUseCase.captions(for: data)
        XCTAssertGreaterThan(caption.count, 0)
    }
}
