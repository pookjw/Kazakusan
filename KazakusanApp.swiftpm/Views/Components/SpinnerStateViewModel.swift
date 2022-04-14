import SwiftUI

final class SpinnerViewStateViewModel: ObservableObject {
    @Published var isAnimating: Bool = false
    
    init() {
        print(#function)
    }
}
