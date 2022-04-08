import Foundation

final class NasaMetadataRepoImpl: NasaMetadataRepo {
    private let nasaApi: NasaApi
    
    init(nasaApi: NasaApi?) {
        if let nasaApi: NasaApi = nasaApi {
            self.nasaApi = nasaApi
        } else {
            self.nasaApi = NasaApiNetwork()
        }
    }
    
    func metadata(from nasaId: String) async throws -> NasaMetadata {
        return try await nasaApi.metadata(from: nasaId)
    }
    
    func captions(from nasaId: String) async throws -> NasaMetadata {
        return try await nasaApi.captions(from: nasaId)
    }
}
