import SwiftUI

struct DataCacheImageView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let url: URL
    @StateObject private var viewModel: DataCacheImageViewModel = .init()
    private let completion: ((Result<Image, Error>) -> Content)
    
    init(url: URL, completion: @escaping ((Result<Image, Error>) -> Content)) {
        self.url = url
        self.completion = completion
    }
    
    init(url: URL) where Content == AnyView {
        self.init(url: url) { result in
            switch result {
            case .success(let image):
                return image
                    .resizable()
                    .scaledToFit()
                    .eraseType()
            case .failure(let error):
                return Label(error.localizedDescription, systemImage: "xmark.octagon")
                    .eraseType()
            }
        }
    }
    
    var body: some View {
        switch viewModel.status {
        case .pending:
            SpinnerView()
                .unfilledColor(Color.gray.opacity(0.5))
                .filledColor((colorScheme == .light) ? .black : .white)
                .frame(width: 50.0, height: 50.0)
                .onAppear {
//                    viewModel.load(url: url)
                }
                .eraseType()
        case .loading:
            SpinnerView()
                .unfilledColor(Color.gray.opacity(0.5))
                .filledColor((colorScheme == .light) ? .black : .white)
                .frame(width: 50.0, height: 50.0)
                .eraseType()
        case let .loaded(uiImage):
            completion(.success(Image(uiImage: uiImage)))
                .eraseType()
        case let .error(error):
            completion(.failure(error))
                .eraseType()
        }
    }
}

#if DEBUG
//struct DataCacheImageView_Previews: PreviewProvider {
//    private static let url: URL = .init(string: "https://images-assets.nasa.gov/image/PIA01120/PIA01120~orig.jpg")!
//    static var previews: some View {
//        DataCacheImageView(url: url)
//    }
//}
#endif
