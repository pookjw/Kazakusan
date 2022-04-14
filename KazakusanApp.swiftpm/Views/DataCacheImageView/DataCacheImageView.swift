import SwiftUI

struct DataCacheImageView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let url: URL
    @StateObject private var stateViewModel: DataCacheImageStateViewModel = .init()
    @ViewBuilder private let completion: ((Result<Image, Error>) -> Content)
    
    init(url: URL, @ViewBuilder completion: @escaping ((Result<Image, Error>) -> Content)) {
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
    
    @ViewBuilder
    var body: some View {
        switch stateViewModel.status {
        case .pending, .loading:
            SpinnerView()
                .unfilledColor(Color.gray.opacity(0.5))
                .filledColor((colorScheme == .light) ? .black : .white)
                .frame(width: 50.0, height: 50.0)
                .onAppear {
                    if case .pending = stateViewModel.status {
                        
                    }
//                    stateViewModel.load(url: url)
                }
        case let .loaded(uiImage):
            completion(.success(Image(uiImage: uiImage)))
        case let .error(error):
            completion(.failure(error))
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
