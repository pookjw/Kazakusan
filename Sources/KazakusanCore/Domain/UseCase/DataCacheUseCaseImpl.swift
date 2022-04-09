import Foundation

public final class DataCacheUseCaseImpl: DataCacheUseCase {
    public nonisolated var didChangeDataCache: AsyncThrowingStream<Void, Error> {
        .init { [dataCacheRepo, weak self] continuation in
            let task: Task = .detached { [weak self] in
                self?.didChangeDataCacheContinuations.append(continuation)
                
                try await withTaskCancellationHandler(
                    handler: { [weak self] in
                        self?.didChangeDataCacheContinuations.removeAll { $0 == continuation }
                    },
                    operation: {
                        for try await _ in dataCacheRepo.didChangeDataCache {
                            continuation.yield(())
                        }
                    }
                )
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public nonisolated var didDeleteAllCaches: AsyncStream<Void> {
        .init { [dataCacheRepo, weak self] continuation in
            let task: Task = .detached { [weak self] in
                self?.didDeleteAllCachesContinuations.append(continuation)
                
                await withTaskCancellationHandler(
                    handler: { [weak self] in
                        self?.didDeleteAllCachesContinuations.removeAll { $0 == continuation }
                    },
                    operation: {
                        for await value in dataCacheRepo.didDeleteAllCaches {
                            continuation.yield(value)
                        }
                    }
                )
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public var fileSize: Int64 {
        get async throws {
            return try await dataCacheRepo.fileSize
        }
    }
    
    private let dataCacheRepo: DataCacheRepo
    private lazy var didChangeDataCacheContinuations: [AsyncThrowingStream<Void, Error>.Continuation] = []
    private lazy var didDeleteAllCachesContinuations: [AsyncStream<Void>.Continuation] = []
    
    public convenience init() {
        self.init(dataCacheRepo: nil)
    }
    
    init(dataCacheRepo: DataCacheRepo?) {
        if let dataCacheRepo: DataCacheRepo = dataCacheRepo {
            self.dataCacheRepo = dataCacheRepo
        } else {
            self.dataCacheRepo = DataCacheRepoImpl.shared
        }
    }
    
    deinit {
        didChangeDataCacheContinuations.forEach { $0.finish() }
        didDeleteAllCachesContinuations.forEach { $0.finish() }
    }
    
    public func dataCache(with identity: String) async throws -> DataCache {
        return try await dataCacheRepo.dataCache(with: identity)
    }
    
    public func createDataCache(identity: String, data: Data) async throws -> DataCache {
        let dataCache: DataCache = try await dataCacheRepo.createDataCache()
        dataCache.identity = identity
        dataCache.data = data
        try await dataCacheRepo.saveChanges()
        return dataCache
    }
    
    public func deleteAllCaches() async throws {
        try await dataCacheRepo.deleteAllCaches()
    }
}
