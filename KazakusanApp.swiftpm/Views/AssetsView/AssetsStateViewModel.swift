import SwiftUI
import KazakusanCore

actor AssetsStateViewModel: ObservableObject {
    enum Error: Swift.Error {
        case noResults
    }
    
    @MainActor @Published var text: String = ""
    @MainActor @Published private(set) var items: [(Int, NasaAsset.Item)] = []
    @MainActor private(set) var itemsCount: Int = 0
    @State private(set) var searchError: Swift.Error?
    private var currentAsset: NasaAsset?
    private let nasaUseCase: NasaUseCase = NasaUseCaseImpl()
    
    init() {
        
    }
    
    func request(text: String) async {
        let searchData: NasaUseCaseSearchData = .init(text: text)
        await updateItems(using: searchData)
    }
    
    func requestRecents() async {
        do {
            let asset: NasaAsset = try await nasaUseCase.recent()
            guard let items: [NasaAsset.Item] = asset.collection?.items else {
                throw Error.noResults
            }
            
            currentAsset = asset
            let enumerated: [(Int, NasaAsset.Item)] = Array(items.enumerated())
            let count: Int = enumerated.count
            
            await MainActor.run { [weak self] in
//                self?.items.append(contentsOf: items)
                self?.items = enumerated
                self?.itemsCount = count
            }
        } catch {
            searchError = error
        }
    }
    
    private func updateItems(using searchData: NasaUseCaseSearchData) async {
        do {
            let asset: NasaAsset = try await nasaUseCase.search(searchData: searchData)
            guard let items: [NasaAsset.Item] = asset.collection?.items else {
                throw Error.noResults
            }
            
            currentAsset = asset
            let enumerated: [(Int, NasaAsset.Item)] = Array(items.enumerated())
            let count: Int = enumerated.count
            
            await MainActor.run { [weak self] in
//                self?.items.append(contentsOf: items)
                self?.items = enumerated
                self?.itemsCount = count
            }
        } catch {
            searchError = error
        }
    }
}
