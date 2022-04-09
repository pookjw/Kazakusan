import XCTest
@testable import KazakusanCore

final class NasaAssetTests: XCTestCase {
    func testCoding() throws {
        guard let sampleJsonURL: URL = Bundle.module.url(forResource: "NasaAssetSample", withExtension: "json") else {
            XCTFail("Could not find: NasaAssetSample.json")
            return
        }
        
        let decoder: JSONDecoder = .init()
        decoder.allowsJSON5 = true
        let encoder: JSONEncoder = .init()
        
        let data: Data = try .init(contentsOf: sampleJsonURL)
        let decoded1: NasaAsset = try decoder.decode(NasaAsset.self, from: data)
        let encoded: Data = try encoder.encode(decoded1)
        let decoded2: NasaAsset = try decoder.decode(NasaAsset.self, from: encoded)
        
        XCTAssertEqual(decoded1.hashValue, decoded2.hashValue)
        XCTAssertEqual(decoded1, decoded2)
    }
}
