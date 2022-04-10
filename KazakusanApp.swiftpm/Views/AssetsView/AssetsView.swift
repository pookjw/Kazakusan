import SwiftUI
import KazakusanCore

struct AssetsView: View {
    @Binding private var searchData: NasaUseCaseSearchData
    @ObservedObject private var viewModel: AssetsViewModel
    @State private var columns: [GridItem] = []
    
    init(searchData: Binding<NasaUseCaseSearchData>?) {
        let searchData: Binding<NasaUseCaseSearchData> = searchData ?? .constant(.init())
        self._searchData = searchData
        
        let viewModel: AssetsViewModel = .init()
        self.viewModel = viewModel
        Task {
            await viewModel.updateItems(using: searchData.wrappedValue)
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            LazyVGrid(columns: columns) {
                ForEach(0..<columns.count, id: \.self) {
                    if let url: URL = viewModel.items[$0].links?.first?.href {
                        AnyView(DataCacheImageView(url: url))
                    } else {
                        AnyView(EmptyView())
                    }
                }
            }
        }
        .onChange(of: searchData, perform: { newValue in
            Task {
                await viewModel.updateItems(using: newValue)
            }
        })
        .onChange(of: viewModel.items, perform: { newValue in
            Task(priority: .high) {
//                var columns: [GridItem] = []
//
//                items.forEach { item in
//                    let column: GridItem = .init(.flexible(minimum: .zero, maximum: 300), spacing: nil, alignment: .center)
//                }
                let columns: [GridItem] = .init(repeating: .init(.fixed(300.0), spacing: nil, alignment: .center), count: newValue.count)
                
                await MainActor.run {
                    self.columns = columns
                }
            }
        })
    }
}

#if DEBUG
struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView(searchData: nil)
    }
}
#endif
