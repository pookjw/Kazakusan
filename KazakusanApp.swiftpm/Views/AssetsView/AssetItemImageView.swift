import SwiftUI
import KazakusanCore

struct FitToAspectRatio: ViewModifier {
    
    let aspectRatio: Double
    let contentMode: SwiftUI.ContentMode
    
    func body(content: Content) -> some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                content.aspectRatio(nil, contentMode: contentMode)
            )
            .clipShape(Rectangle())
    }
    
}

extension Image {
    func fitToAspect(_ aspectRatio: Double, contentMode: SwiftUI.ContentMode) -> some View {
        self.resizable()
            .scaledToFill()
            .modifier(FitToAspectRatio(aspectRatio: aspectRatio, contentMode: contentMode))
    }
}

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
                    // https://stackoverflow.com/a/70510040/17473716
                    return Color.clear
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay {
                            image
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(nil, contentMode: .fill)
                        }
                        .clipShape(Rectangle())
                        .cornerRadius(10.0, antialiased: true)
                        .shadow(color: (colorScheme == .light) ? .black.opacity(0.4) : .white.opacity(0.2), radius: 2.5)
                        .eraseType()
                case let .failure(error):
                    return Text(error.localizedDescription)
                        .eraseType()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            // https://stackoverflow.com/a/63558599/17473716
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
