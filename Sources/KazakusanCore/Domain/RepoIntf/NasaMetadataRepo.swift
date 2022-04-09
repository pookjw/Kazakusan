import Foundation

protocol NasaMetadataRepo {
    func metadata(from nasaId: String) async throws -> NasaMetadata
    
    func captions(from nasaId: String) async throws -> NasaMetadata
}
