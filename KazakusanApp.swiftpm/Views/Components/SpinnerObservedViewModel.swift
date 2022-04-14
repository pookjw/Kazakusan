import SwiftUI

final class SpinnerObservedViewModel: ObservableObject {
    @Published var lineWidth: CGFloat = 4.0
    @Published var unfilledColor: Color = .gray.opacity(0.5)
    @Published var filledColor: Color = .white
    @Published var radians: Double = CGFloat.pi / 2.0
    @Published var duration: Double = 1.0
    @Published var isAnimating: Bool = false
}
