import SwiftUI

struct ContentView: View {
    @State var text: String = ""
    
    var body: some View {
        NavigationView {
            AssetsView()
        }
    }
}
