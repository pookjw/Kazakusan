import SwiftUI
import KazakusanCore

struct AssetsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var stateViewModel: AssetsStateViewModel = .init()
    private let tasksBag: TasksBag<Void, Never> = .init()
    
    var body: some View {
        List(Array(stateViewModel.items.enumerated()), id: \.1.hashValue) { (index, item) in
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

                if index < (stateViewModel.itemsCount - 1) {
                    Color
                        .gray
                        .opacity(0.5)
                        .frame(height: 0.5)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .onAppear {
            tasksBag.store(task: .init(operation: {
                await stateViewModel.requestRecents()
            }))
        }
//        .overlay(alignment: .center) {
//            SpinnerView()
//                .unfilledColor(Color.gray.opacity(0.5))
//                .filledColor((colorScheme == .light) ? .black : .white)
//                .padding(10.0)
//                .background(.ultraThinMaterial)
//                .frame(width: 60.0, height: 60.0)
//        }
        .searchable(text: $stateViewModel.text)
        .onSubmit(of: .search, {
            tasksBag.store(task: .init {
                await stateViewModel.request(text: stateViewModel.text)
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
