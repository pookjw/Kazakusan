import SwiftUI

struct ContentView: View {
    var body: some View {
        AssetsView(searchData: .constant(.init(text: "Mars")))
    }
}
