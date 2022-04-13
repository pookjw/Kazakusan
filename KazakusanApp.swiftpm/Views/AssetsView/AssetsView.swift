import SwiftUI
import KazakusanCore

struct AssetsView: View {
    @State private var text: String = ""
    @StateObject private var viewModel: AssetsViewModel = .init()
    private let tasksBag: TasksBag<Void, Never> = .init()
    
    var body: some View {
        List(viewModel.items, id: \.1.hashValue) { (index, item) in
            VStack {
                switch item.data?.first?.mediaType {
                case .image:
                    AssetItemImageView(assetItem: item)
                case .video:
                    Text("Video type is not supported yet.")
                case .audio:
                    Text("Audio type is not supported yet.")
                default:
                    Text("No data was found.")
                        .onAppear {
                            print(item)
                        }
                }
                
                if index < (viewModel.itemsCount - 1) {
                    Color
                        .gray
                        .opacity(0.5)
                        .frame(height: 0.5)
                }
            }
            .listRowSeparator(.hidden)
        }
        .onAppear {
            tasksBag.store(task: .init(operation: {
                await viewModel.requestRecents()
            }))
        }
        .searchable(text: $text)
        .onSubmit(of: .search, {
            tasksBag.store(task: .init {
                await viewModel.request(text: text)
            })
        })
        .navigationTitle("Assets")
    }
}

#if DEBUG
struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
#endif
