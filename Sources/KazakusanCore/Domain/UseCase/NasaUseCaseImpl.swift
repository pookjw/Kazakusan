import Foundation
import OSLog

public final class NasaUseCaseImpl: NasaUseCase {
    public enum Error: LocalizedError {
        case locationNotFound
        case typeError
        case statusCode(Int)
        case previousNotAvailable
        case nextNotAvailable
        case idNotFound

        public var errorDescription: String? {
            switch self {
            case .locationNotFound:
                return "(번역) location이 존재하지 않습니다."
            case .typeError:
                return "(번역) Type 변환을 할 수 없습니다."
            case .statusCode(let code):
                return "(번역) 서버 오류 \(code)"
            case .previousNotAvailable:
                return "(번역) 이전 페이지를 불러 올 수 없습니다."
            case .nextNotAvailable:
                return "(번역) 다음 페이지를 불러 올 수 없습니다."
            case .idNotFound:
                return "(번역) ID를 찾을 수 없습니다."
            }
        }
    }

    private let nasaAssetRepo: NasaAssetRepo
    private let nasaMetadataRepo: NasaMetadataRepo

    public convenience init() {
        self.init(nasaAssetRepo: nil, nasaMetadataRepo: nil)
    }
    
    init(nasaAssetRepo: NasaAssetRepo?,
         nasaMetadataRepo: NasaMetadataRepo?) {
        if let nasaAssetRepo: NasaAssetRepo = nasaAssetRepo {
            self.nasaAssetRepo = nasaAssetRepo
        } else {
            self.nasaAssetRepo = NasaAssetRepoImpl(nasaApi: nil)
        }
        
        if let nasaMetadataRepo: NasaMetadataRepo = nasaMetadataRepo {
            self.nasaMetadataRepo = nasaMetadataRepo
        } else {
            self.nasaMetadataRepo = NasaMetadataRepoImpl(nasaApi: nil)
        }
    }
    
    public func search(text: String?,
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
                       yearEnd: Int?) async throws -> NasaAsset {
        return try await nasaAssetRepo.search(text: text, center: center, description: description, description508: description508, keywords: keywords, location: location, mediaType: mediaType, nasaId: nasaId, page: page, photographer: photographer, secondaryCreator: secondaryCreator, title: title, yearStart: yearStart, yearEnd: yearEnd)
    }
    
    public func previous(for asset: NasaAsset) async throws -> NasaAsset {
        guard let url: URL = asset.collection?.links?.first(where: { $0.rel == "prev" })?.href else {
            throw Error.previousNotAvailable
        }
        
        return try await process(from: url)
    }
    
    public func next(for asset: NasaAsset) async throws -> NasaAsset {
        guard let url: URL = asset.collection?.links?.first(where: { $0.rel == "next" })?.href else {
            throw Error.nextNotAvailable
        }
        
        return try await process(from: url)
    }
    
    public func recent() async throws -> NasaAsset {
        return try await nasaAssetRepo.recent()
    }
    
    public func popular() async throws -> NasaAsset {
        return try await nasaAssetRepo.popular()
    }
    
    public func asset(from data: NasaAsset.Item.Data) async throws -> NasaAsset {
        guard let nasaId: String = data.nasaId else {
            throw Error.idNotFound
        }
        
        return try await nasaAssetRepo.asset(from: nasaId)
    }

    public func metadata(for asset: NasaAsset.Item.Data) async throws -> [String: Any] {
        guard let nasaId: String = asset.nasaId else {
            throw Error.idNotFound
        }
        
        let metadata: NasaMetadata = try await nasaMetadataRepo.metadata(from: nasaId)

        guard let url: URL = metadata.location else {
            throw Error.locationNotFound
        }

        let data: Data = try await download(from: url)
        
        guard let dic: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any] else {
            throw Error.typeError
        }
        
        return dic
    }

    public func captions(for asset: NasaAsset.Item.Data) async throws -> Data {
        guard let nasaId: String = asset.nasaId else {
            throw Error.idNotFound
        }
        
        let metadata: NasaMetadata = try await nasaMetadataRepo.captions(from: nasaId)

        guard let url: URL = metadata.location else {
            throw Error.locationNotFound
        }

        return try await download(from: url)
    }
    
    private func download(from url: URL) async throws -> Data {
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
        
        return try await data
    }
    
    private func process<T: Decodable>(from url: URL) async throws -> T {
        async let data: Data = try download(from: url)
        let decoder: JSONDecoder = .init()
        decoder.allowsJSON5 = true
        return try await decoder.decode(T.self, from: data)
    }
}
