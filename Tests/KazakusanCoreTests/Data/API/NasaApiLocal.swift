import Foundation
@testable import KazakusanCore

final class NasaApiLocal: NasaApi {
    enum Error: LocalizedError {
        case resourceNotFound(String)
        case notSupportedOrder(String)
        
        var errorDescription: String? {
            switch self {
            case let .resourceNotFound(name):
                return "(번역) \(name)를 찾을 수 없습니다."
            case let .notSupportedOrder(order):
                return "(번역) \(order)는 지원하지 않습니다."
            }
        }
    }
    
    func search(q: String?, center: String?, description: String?, description508: String?, keywords: Set<String>?, location: String?, mediaType: Set<NasaAsset.Item.Data.MediaType>?, nasaId: String?, page: Int?, photographer: String?, secondaryCreator: String?, title: String?, yearStart: Int?, yearEnd: Int?) async throws -> NasaAsset {
        return try result(for: "NasaApiSearchSample")
    }
    
    func asset(by order: String) async throws -> NasaAsset {
        switch order {
        case "recent":
            return try result(for: "NasaApiAssetsByRecentSample")
        case "popular":
            return try result(for: "NasaApiAssetsByPopularSample")
        default:
            throw Error.notSupportedOrder(order)
        }
    }
    
    func _asset(by order: String) async throws -> NasaAsset {
        return try await asset(by: order)
    }
    
    func asset(from nasaId: String) async throws -> NasaAsset {
        return try result(for: "NasaApiAssetSample")
    }
    
    func metadata(from nasaId: String) async throws -> NasaMetadata {
        return try result(for: "NasaApiMetadataSample")
    }
    
    func captions(from nasaId: String) async throws -> NasaMetadata {
        return try result(for: "NasaApiCaptionsSample")
    }
    
    private func result<T: Decodable>(for name: String) throws -> T {
        guard let url: URL = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw Error.resourceNotFound(name)
        }
        
        let data: Data = try .init(contentsOf: url)
        let decoder: JSONDecoder = .init()
        decoder.allowsJSON5 = true
        let asset: T = try decoder.decode(T.self, from: data)
        return asset
    }
}
