import Foundation

protocol NasaAssetRepo {
    func search(text: String?,
                center: String?,
                description: String?,
                description508: String?,
                keywords: [String]?,
                location: String?,
                mediaType: [NasaAsset.Item.Data.MediaType]?,
                nasaId: String?,
                page: Int?,
                photographer: String?,
                secondaryCreator: String?,
                title: String?,
                yearStart: Int?,
                yearEnd: Int?) async throws -> NasaAsset
    
    func recent() async throws -> NasaAsset
    
    func popular() async throws -> NasaAsset
    
    func asset(from nasaId: String) async throws -> NasaAsset
}
