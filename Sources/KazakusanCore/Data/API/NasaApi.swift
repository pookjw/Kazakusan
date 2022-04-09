import Foundation

protocol NasaApi {
    func search(q: String?,
                center: String?,
                description: String?,
                description508: String?,
                keywords: Set<String>?,
                location: String?,
                mediaType: Set<NasaAsset.Item.Data.MediaType>?,
                nasaId: String?,
                page: Int?,
                photographer: String?,
                secondaryCreator: String?,
                title: String?,
                yearStart: Int?,
                yearEnd: Int?) async throws -> NasaAsset
    
    func asset(by order: String) async throws -> NasaAsset
    
    func _asset(by order: String) async throws -> NasaAsset
    
    func asset(from nasaId: String) async throws -> NasaAsset
    
    func metadata(from nasaId: String) async throws -> NasaMetadata
    
    func captions(from nasaId: String) async throws -> NasaMetadata
}
