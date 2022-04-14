import SwiftUI
import KazakusanCore

struct AssetItemImageView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let assetItem: NasaAsset.Item
    
    init(assetItem: NasaAsset.Item) {
        self.assetItem = assetItem
    }
    
    @ViewBuilder
    var body: some View {
        if let url: URL = assetItem.links?.first?.href {
            DataCacheImageView(url: url) { result -> AnyView in
                switch result {
                case let .success(image):
                    return image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10.0, antialiased: true)
                        .shadow(color: (colorScheme == .light) ? .black.opacity(0.4) : .white.opacity(0.4), radius: 2.5)
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
                .multilineTextAlignment(.center)
                .font(Font.system(.callout))
        } else {
            EmptyView()
        }
    }
}
