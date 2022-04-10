import SwiftUI
import KazakusanCore

actor AssetsViewModel: ObservableObject {
    enum Error: Swift.Error {
        case noResults
    }
    
    @MainActor @Published private(set) var items: [NasaAsset.Item] = []
    @State private(set) var searchError: Swift.Error?
    private var currentAsset: NasaAsset?
    private let nasaUseCase: NasaUseCase = NasaUseCaseImpl()
    
    init() {
        
    }
    
    func updateItems(using searchData: NasaUseCaseSearchData) async {
        do {
            let asset: NasaAsset = try await nasaUseCase.search(searchData: searchData)
            guard let items: [NasaAsset.Item] = asset.collection?.items else {
                throw Error.noResults
            }
            
            currentAsset = asset
            await MainActor.run { [weak self] in
                self?.items.append(contentsOf: items)
            }
        } catch {
            searchError = error
        }
    }
}
