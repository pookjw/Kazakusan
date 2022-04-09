import Foundation

final class NasaAssetRepoImpl: NasaAssetRepo {
    private let nasaApi: NasaApi
    
    init(nasaApi: NasaApi?) {
        if let nasaApi: NasaApi = nasaApi {
            self.nasaApi = nasaApi
        } else {
            self.nasaApi = NasaApiNetwork()
        }
    }
    
    func search(text: String?, center: String?, description: String?, description508: String?, keywords: Set<String>?, location: String?, mediaType: Set<NasaAsset.Item.Data.MediaType>?, nasaId: String?, page: Int?, photographer: String?, secondaryCreator: String?, title: String?, yearStart: Int?, yearEnd: Int?) async throws -> NasaAsset {
        return try await nasaApi.search(q: text, center: center, description: description, description508: description508, keywords: keywords, location: location, mediaType: mediaType, nasaId: nasaId, page: page, photographer: photographer, secondaryCreator: secondaryCreator, title: title, yearStart: yearStart, yearEnd: yearEnd)
    }
    
    func recent() async throws -> NasaAsset {
        return try await nasaApi.asset(by: "recent")
    }
    
    func popular() async throws -> NasaAsset {
        return try await nasaApi.asset(by: "popular")
    }
    
    func asset(from nasaId: String) async throws -> NasaAsset {
        return try await nasaApi.asset(from: nasaId)
    }
}
