import Foundation
import OSLog

final class NasaApiNetwork: NasaApi {
    private enum Error: LocalizedError {
        case invalidURL
        case typeError
        case statusCode(Int)
        case itemNotFound
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "(번역) 올바르지 않은 URL 입니다."
            case .typeError:
                return "(번역) Type 변환을 할 수 없습니다."
            case .statusCode(let code):
                return "(번역) 서버 오류 \(code)"
            case .itemNotFound:
                return "(번역) 아이템을 찾을 수 없습니다."
            }
        }
    }
    
    private var apiURLComponents: URLComponents {
        var baseURLComponents: URLComponents = .init()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = "images-api.nasa.gov"
        return baseURLComponents
    }
    
    private var assetsURLComponents: URLComponents {
        var baseURLComponents: URLComponents = .init()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = "images-assets.nasa.gov"
        return baseURLComponents
    }
    
    /// - Parameters:
    ///     - q: Free text search terms to compare to all indexed metadata.
    ///     - center: NASA center which published the media.
    ///     - description: Terms to search for in “Description” fields.
    ///     - description508: Terms to search for in “508 Description” fields.
    ///     - keywords: Terms to search for in “Keywords” fields.
    ///     - location: Terms to search for in “Location” fields.
    ///     - mediaType: Media types to restrict the search to.
    ///     - nasaId: The media asset’s NASA ID.
    ///     - page: Page number, starting at 1, of results to get.
    ///     - photographer: The primary photographer’s name.
    ///     - secondaryCreator: A secondary photographer/videographer’s name.
    ///     - title: Terms to search for in “Title” fields.
    ///     - yearStart: The start year for results. Format: YYYY.
    ///     - yearEnd: The end year for results. Format: YYYY.
    func search(q: String?,
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
                yearEnd: Int?) async throws -> NasaAsset {
        var urlComponents: URLComponents = apiURLComponents
        urlComponents.path = "/search"
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(.init(name: "q", value: q ?? ""))
        if let center: String = center {
            queryItems.append(.init(name: "center", value: center))
        }
        if let description: String = description {
            queryItems.append(.init(name: "description", value: description))
        }
        if let description508: String = description508 {
            queryItems.append(.init(name: "description_508", value: description508))
        }
        if let keywords: [String] = keywords, !keywords.isEmpty {
            let result: String = keywords.joined(separator: ",")
            queryItems.append(.init(name: "keywords", value: result))
        }
        if let location: String = location {
            queryItems.append(.init(name: "location", value: location))
        }
        if let mediaType: [NasaAsset.Item.Data.MediaType] = mediaType, !mediaType.isEmpty {
            let reuslt: String = mediaType
                .map { $0.rawValue }
                .joined(separator: ",")
            queryItems.append(.init(name: "media_type", value: reuslt))
        }
        if let nasaId: String = nasaId {
            queryItems.append(.init(name: "nasa_id", value: nasaId))
        }
        if let page: Int = page {
            queryItems.append(.init(name: "page", value: String(page)))
        }
        if let photographer: String = photographer {
            queryItems.append(.init(name: "photographer", value: photographer))
        }
        if let secondaryCreator: String = secondaryCreator {
            queryItems.append(.init(name: "secondary_creator", value: secondaryCreator))
        }
        if let title: String = title {
            queryItems.append(.init(name: "title", value: title))
        }
        if let yearStart: Int = yearStart {
            queryItems.append(.init(name: "year_start", value: String(yearStart)))
        }
        if let yearEnd: Int = yearEnd {
            queryItems.append(.init(name: "year_end", value: String(yearEnd)))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    func asset(by order: String) async throws -> NasaAsset {
        var urlComponents: URLComponents = assetsURLComponents
        urlComponents.path = "/\(order).json"
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    func _asset(by order: String) async throws -> NasaAsset {
        var urlComponents: URLComponents = apiURLComponents
        urlComponents.path = "/asset/"
        urlComponents.queryItems = [.init(name: "orderby", value: order)]
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    func asset(from nasaId: String) async throws -> NasaAsset {
        var urlComponents: URLComponents = apiURLComponents
        urlComponents.path = "/asset/\(nasaId)"
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    func metadata(from nasaId: String) async throws -> NasaMetadata {
        var urlComponents: URLComponents = apiURLComponents
        urlComponents.path = "/metadata/\(nasaId)"
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    func captions(from nasaId: String) async throws -> NasaMetadata {
        var urlComponents: URLComponents = apiURLComponents
        urlComponents.path = "/captions/\(nasaId)"
        
        guard let url: URL = urlComponents.url else {
            throw Error.invalidURL
        }
        
        return try await process(url: url)
    }
    
    private func process<T: Decodable>(url: URL) async throws -> T {
        Logger().info("\(url)")
        
        let configuration: URLSessionConfiguration = .ephemeral
        async let (data, response): (Data, URLResponse) = URLSession(configuration: configuration).data(from: url)
        
        guard let response: HTTPURLResponse = try await response as? HTTPURLResponse else {
            throw Error.typeError
        }
        
        let statusCode: Int = response.statusCode
        
        guard statusCode == 200 else {
            throw Error.statusCode(statusCode)
        }
        
        let decoder: JSONDecoder = .init()
        decoder.allowsJSON5 = true
        return try await decoder.decode(T.self, from: data)
    }
}
