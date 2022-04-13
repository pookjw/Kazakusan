import SwiftUI
import KazakusanCore

struct AssetItemImageView: View {
    private let assetItem: NasaAsset.Item
    
    init(assetItem: NasaAsset.Item) {
        self.assetItem = assetItem
    }
    
    var body: some View {
        VStack {
            if let url: URL = assetItem.links?.first?.href {
                DataCacheImageView(url: url) { result -> AnyView in
                    switch result {
                    case let .success(image):
                        return image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10.0, antialiased: true)
                            .eraseType()
                    case let .failure(error):
                        return Text(error.localizedDescription)
                            .eraseType()
                    }
                }
            } else {
                EmptyView()
            }
            
            if let data: NasaAsset.Item.Data = assetItem.data?.first {
                Text(data.title ?? "nil")
            } else {
                EmptyView()
            }
        }
    }
}
