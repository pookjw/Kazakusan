import CoreData

@globalActor actor DataCacheRepoImpl: DataCacheRepo {
    enum Error: Swift.Error {
        case noUrlFound
        case invalidFileSize
        case noDataCacheFround(identity: String)
        case typeError
    }
    
    static let shared: DataCacheRepoImpl = .init()
    
    nonisolated var didChangeDataCache: AsyncThrowingStream<(Notification.Name, [AnyHashable : Any]?), Swift.Error> {
        .init { [weak self] continuation in
            let task: Task = .detached { [weak self] in
                do {
                    guard let context: NSManagedObjectContext = try await self?.context else {
                        continuation.finish()
                        return
                    }
                    
                    let didChangeDataCacheObserver: NSObjectProtocol = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                                                                                              object: context,
                                                                                                              queue: nil) { notification in
                        continuation.yield((notification.name, notification.userInfo))
                    }
                    
                    await self?.addDidChangeDataCacheContinuation(continuation)
                    await self?.addDidChangeDataCacheObserver(didChangeDataCacheObserver)
                    
                    await withTaskCancellationHandler(
                        handler: { [weak self] in
                            NotificationCenter.default.removeObserver(didChangeDataCacheObserver)
                            Task { @DataCacheRepoImpl [weak self] in
                                await self?.removeDidChangeDataCacheContinuation(continuation)
                                await self?.removeDidChangeDataCacheObserver(didChangeDataCacheObserver)
                            }
                        },
                        operation: {
                            
                        }
                    )
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    nonisolated var didDeleteAllCaches: AsyncStream<Void> {
        .init { [weak self] continuation in
            let task: Task = .detached { [weak self] in
                await self?.addDidDeleteAllCachesContinuation(continuation)
                
                await withTaskCancellationHandler(
                    handler: { [weak self] in
                        Task { @DataCacheRepoImpl [weak self] in
                            await self?.removeDidDeleteAllCachesContinuation(continuation)
                        }
                    },
                    operation: {
                        
                    }
                )
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private var storeContainer: NSPersistentContainer {
        get async throws {
            try await CoreDataStack.shared.storeContainer(for: modelName, momNames: momNames)
        }
    }
    
    private var context: NSManagedObjectContext {
        get async throws {
            _ = try await storeContainer
            return try await CoreDataStack.shared.context(for: modelName)
        }
    }
    
    private var readTransactionStream: AsyncStream<Bool> {
        .init { [weak self] continuation in
            let task: Task = .detached { [weak self] in
                await self?.addReadTransactionStreamContinuation(continuation)
                
                await withTaskCancellationHandler(
                    handler: { [weak self] in
                        Task { @DataCacheRepoImpl [weak self] in
                            await self?.removeReadTransactionStreamContinuation(continuation)
                        }
                    },
                    operation: {
                        
                    }
                )
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private var writeTransactionStream: AsyncStream<Bool> {
        .init { [weak self] continuation in
            let task: Task = .detached { [weak self] in
                await self?.addWriteTransactionStreamContinuation(continuation)
                
                await withTaskCancellationHandler(
                    handler: { [weak self] in
                        Task { @DataCacheRepoImpl [weak self] in
                            await self?.removeWriteTransactionStreamContinuation(continuation)
                        }
                    },
                    operation: {
                        
                    }
                )
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private lazy var didChangeDataCacheObservers: [NSObjectProtocol] = []
    private lazy var didChangeDataCacheContinuations: [AsyncThrowingStream<(Notification.Name, [AnyHashable : Any]?), Swift.Error>.Continuation] = []
    private lazy var didDeleteAllCachesContinuations: [AsyncStream<Void>.Continuation] = []
    private lazy var readTransactionStreamContinuations: [AsyncStream<Bool>.Continuation] = []
    private lazy var writeTransactionStreamContinuations: [AsyncStream<Bool>.Continuation] = []
    private lazy var inReadTransaction: Bool = false
    private lazy var inWriteTransaction: Bool = false
    
    private var modelName: String { "DataCache" }
    private var momNames: [String] { ["DataCache_v1"] }
    
    var fileSize: Int64 {
        get async throws {
            guard let url: URL = try await storeContainer.persistentStoreCoordinator.persistentStores.first?.url else {
                throw Error.noUrlFound
            }
            
            let attributes: [FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: url.path)
            
            guard let fileSize: Int64 = attributes[.size] as? Int64 else {
                throw Error.invalidFileSize
            }
            
            return fileSize
        }
    }
    
    private init() { }
    
    deinit {
        didChangeDataCacheObservers.forEach { NotificationCenter.default.removeObserver($0) }
        didChangeDataCacheContinuations.forEach { $0.finish() }
        didDeleteAllCachesContinuations.forEach { $0.finish() }
        readTransactionStreamContinuations.forEach { $0.finish() }
        writeTransactionStreamContinuations.forEach { $0.finish() }
    }
    
    func saveChanges() async throws {
        if inReadTransaction {
            for await inReadTransaction in readTransactionStream {
                if !inReadTransaction {
                    break
                }
            }
        }
        
        setInWriteTransaction(true)
        try await CoreDataStack.shared.saveChanges(for: modelName)
        setInWriteTransaction(false)
    }
    
    nonisolated func dataCache(with identity: String) async throws -> DataCache {
        if await inWriteTransaction {
            for await inWriteTransaction in await writeTransactionStream {
                if !inWriteTransaction {
                    break
                }
            }
        }
        
        await setInReadTransaction(true)
        
        let fetchRequest: NSFetchRequest<DataCache> = await .init(entityName: modelName)
        let predicate: NSPredicate = .init(format: "%K = %@", #keyPath(DataCache.identity), identity)
        fetchRequest.predicate = predicate
        
        let context: NSManagedObjectContext = try await context
        
        do {
            let result: DataCache = try await withCheckedThrowingContinuation { continuation in
                context.perform {
                    do {
                        guard let dataCache: DataCache = try context.fetch(fetchRequest).first else {
                            throw Error.noDataCacheFround(identity: identity)
                        }
                        continuation.resume(returning: dataCache)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            await setInReadTransaction(false)
            return result
        } catch {
            await setInReadTransaction(false)
            throw error
        }
    }
    
    nonisolated func createDataCache() async throws -> DataCache {
        let context: NSManagedObjectContext = try await context
        return .init(context: context)
    }
    
    func deleteAllCaches() async throws {
        guard let fetchRequest: NSFetchRequest<NSFetchRequestResult> = await NSFetchRequest<DataCache>(entityName: DataCacheRepoImpl.shared.modelName) as? NSFetchRequest<NSFetchRequestResult> else {
            throw Error.typeError
        }
        
        let storeContainer: NSPersistentContainer = try await storeContainer
        let deleteRequest: NSBatchDeleteRequest = .init(fetchRequest: fetchRequest)
        deleteRequest.affectedStores = storeContainer.persistentStoreCoordinator.persistentStores
        let context: NSManagedObjectContext = try await context
        let _: Void = try await withCheckedThrowingContinuation { [weak self] continuation in
            context.perform {
                do {
                    try storeContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
                    Task { [weak self] in
                        await self?.didDeleteAllCachesContinuations.forEach { $0.yield(()) }
                        continuation.resume(returning: ())
                    }
                } catch {
                    Task { [weak self] in
                        await self?.didDeleteAllCachesContinuations.forEach { $0.yield(()) }
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func addDidChangeDataCacheObserver(_ didChangeDataCacheObserver: NSObjectProtocol) {
        didChangeDataCacheObservers.append(didChangeDataCacheObserver)
    }
    
    private func removeDidChangeDataCacheObserver(_ didChangeDataCacheObserver: NSObjectProtocol) {
        didChangeDataCacheObservers.removeAll { $0 === didChangeDataCacheObserver }
    }
    
    private func addDidChangeDataCacheContinuation(_ didChangeDataCacheContinuation: AsyncThrowingStream<(Notification.Name, [AnyHashable : Any]?), Swift.Error>.Continuation) {
        didChangeDataCacheContinuations.append(didChangeDataCacheContinuation)
    }
    
    private func removeDidChangeDataCacheContinuation(_ didChangeDataCacheContinuation: AsyncThrowingStream<(Notification.Name, [AnyHashable : Any]?), Swift.Error>.Continuation) {
        didChangeDataCacheContinuations.removeAll { $0 == didChangeDataCacheContinuation }
    }
    
    private func addDidDeleteAllCachesContinuation(_ didDeleteAllCachesContinuation: AsyncStream<Void>.Continuation) {
        didDeleteAllCachesContinuations.append(didDeleteAllCachesContinuation)
    }
    
    private func removeDidDeleteAllCachesContinuation(_ didDeleteAllCachesContinuation: AsyncStream<Void>.Continuation) {
        didDeleteAllCachesContinuations.removeAll { $0 == didDeleteAllCachesContinuation }
    }
    
    private func addReadTransactionStreamContinuation(_ readTransactionStreamContinuation: AsyncStream<Bool>.Continuation) {
        readTransactionStreamContinuations.append(readTransactionStreamContinuation)
    }
    
    private func removeReadTransactionStreamContinuation(_ readTransactionStreamContinuation: AsyncStream<Bool>.Continuation) {
        readTransactionStreamContinuations.removeAll { $0 == readTransactionStreamContinuation }
    }
    
    private func addWriteTransactionStreamContinuation(_ writeTransactionStreamContinuation: AsyncStream<Bool>.Continuation) {
        writeTransactionStreamContinuations.append(writeTransactionStreamContinuation)
    }
    
    private func removeWriteTransactionStreamContinuation(_ writeTransactionStreamContinuation: AsyncStream<Bool>.Continuation) {
        writeTransactionStreamContinuations.removeAll { $0 == writeTransactionStreamContinuation }
    }
    
    private func setInReadTransaction(_ inReadTransaction: Bool) {
        self.inReadTransaction = inReadTransaction
        readTransactionStreamContinuations.forEach { $0.yield(inReadTransaction) }
    }
    
    private func setInWriteTransaction(_ inWriteTransaction: Bool) {
        self.inWriteTransaction = inWriteTransaction
        writeTransactionStreamContinuations.forEach { $0.yield(inWriteTransaction) }
    }
}
