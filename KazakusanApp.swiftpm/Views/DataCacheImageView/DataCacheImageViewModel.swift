import SwiftUI
import OSLog
import KazakusanCore

final class DataCacheImageViewModel: ObservableObject {
    enum Status {
        case pending, loading, error(Swift.Error), loaded(UIImage)
    }
    
    enum Error: Swift.Error {
        case failedToInitUIImage, statusCode(Int), typeError
    }
    
    @MainActor @Published private(set) var status: Status = .pending
    private let dataCacheUseCase: DataCacheUseCase
    private var loadTask: Task<Void, Never>?
    
    init(dataCacheUseCase: DataCacheUseCase? = nil) {
        if let dataCacheUseCase: DataCacheUseCase = dataCacheUseCase {
            self.dataCacheUseCase = dataCacheUseCase
        } else {
            self.dataCacheUseCase = DataCacheUseCaseImpl()
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    func load(url: URL) {
        loadTask = .init(priority: .high, operation: { [weak self] in
            let setStatus: (Status) -> () = { [weak self] status in
                Task { @MainActor [weak self] in
                    self?.status = status
                }
            }
            
            setStatus(.loading)
            
            guard let dataCache: DataCache = try? await dataCacheUseCase.dataCache(with: url.absoluteString),
                  let data: Data = dataCache.data,
                  let uiImage: UIImage = .init(data: data) else {
                do {
    //                Logger().info("Not cached: \(url.absoluteString)")
                    
                    let data: Data = try await download(from: url)
                    guard let uiImage: UIImage = .init(data: data) else {
                        throw Error.failedToInitUIImage
                    }
                    
                    setStatus(.loaded(uiImage))
                    try? await saveCache(uiImage: uiImage, url: url)
                } catch {
                    setStatus(.error(error))
                }
                return
            }
            
    //        Logger().info("Cached: \(url.absoluteString)")
            setStatus(.loaded(uiImage))
        })
    }
    
    func resign() {
        
    }
    
    private func download(from url: URL) async throws -> Data {
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
    
    private func saveCache(uiImage: UIImage, url: URL) async throws {
        guard let data: Data = uiImage.pngData() else {
            Logger().error("Unable to get PNG Data from UIImage.")
            return
        }
        _ = try await dataCacheUseCase.createDataCache(identity: url.absoluteString, data: data)
    }
}
