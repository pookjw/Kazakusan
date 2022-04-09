import Foundation

public protocol NasaUseCase {
    func search(text: String?,
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
    
    func previous(for asset: NasaAsset) async throws -> NasaAsset
    
    func next(for asset: NasaAsset) async throws -> NasaAsset
    
    func asset(from data: NasaAsset.Item.Data) async throws -> NasaAsset
    
    func recent() async throws -> NasaAsset
    
    func popular() async throws -> NasaAsset
    
    func metadata(for asset: NasaAsset.Item.Data) async throws -> [String: Any]
    
    func captions(for asset: NasaAsset.Item.Data) async throws -> Data
}
