import Foundation

public struct NasaUseCaseSearchData: Equatable, Hashable {
    public let text: String?
    public let center: String?
    public let description: String?
    public let description508: String?
    public let keywords: Set<String>?
    public let location: String?
    public let mediaType: Set<NasaAsset.Item.Data.MediaType>?
    public let nasaId: String?
    public let page: Int?
    public let photographer: String?
    public let secondaryCreator: String?
    public let title: String?
    public let yearStart: Int?
    public let yearEnd: Int?
    
    public init(text: String? = nil,
                center: String? = nil,
                description: String? = nil,
                description508: String? = nil,
                keywords: Set<String>? = nil,
                location: String? = nil,
                mediaType: Set<NasaAsset.Item.Data.MediaType>? = nil,
                nasaId: String? = nil,
                page: Int? = nil,
                photographer: String? = nil,
                secondaryCreator: String? = nil,
                title: String? = nil,
                yearStart: Int? = nil,
                yearEnd: Int? = nil) {
        self.text = text
        self.center = center
        self.description = description
        self.description508 = description508
        self.keywords = keywords
        self.location = location
        self.mediaType = mediaType
        self.nasaId = nasaId
        self.page = page
        self.photographer = photographer
        self.secondaryCreator = secondaryCreator
        self.title = title
        self.yearStart = yearStart
        self.yearEnd = yearEnd
    }
}

public protocol NasaUseCase {
    func search(searchData: NasaUseCaseSearchData) async throws -> NasaAsset
    
    func previous(for asset: NasaAsset) async throws -> NasaAsset
    
    func next(for asset: NasaAsset) async throws -> NasaAsset
    
    func asset(from data: NasaAsset.Item.Data) async throws -> NasaAsset
    
    func recent() async throws -> NasaAsset
    
    func popular() async throws -> NasaAsset
    
    func metadata(for asset: NasaAsset.Item.Data) async throws -> [String: Any]
    
    func captions(for asset: NasaAsset.Item.Data) async throws -> Data
}
