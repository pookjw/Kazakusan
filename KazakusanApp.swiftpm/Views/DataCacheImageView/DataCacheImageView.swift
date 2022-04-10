import SwiftUI

struct DataCacheImageView: View {
    @ObservedObject private var viewModel: DataCacheImageViewModel
    private let completion: ((Result<Image, Error>) -> AnyView?)?
    
    init(url: URL, completion: ((Result<Image, Error>) -> AnyView?)? = nil) {
        self.viewModel = .init(url: url)
        self.completion = completion
    }
    
    var body: some View {
        switch viewModel.status {
        case .pending, .loading:
            return AnyView(ProgressView())
        case let .loaded(uiImage):
            let image: Image = .init(uiImage: uiImage)
            
            if let view: AnyView = completion?(.success(image)) {
                return view
            } else {
                return AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            }
        case let .error(error):
            if let view: AnyView = completion?(.failure(error)) {
                return view
            } else {
                let label: Label = .init(error.localizedDescription, systemImage: "xmark.octagon")
                return AnyView(label)
            }
        }
    }
}

#if DEBUG
struct DataCacheImageView_Previews: PreviewProvider {
    private static let url: URL = .init(string: "https://images-assets.nasa.gov/image/PIA01120/PIA01120~orig.jpg")!
    static var previews: some View {
        DataCacheImageView(url: url)
        
        DataCacheImageView(url: url) { result in
            switch result {
            case let .success(image):
                return AnyView(image.antialiased(true))
            case .failure:
                return nil
            }
        }
    }
}
#endif
