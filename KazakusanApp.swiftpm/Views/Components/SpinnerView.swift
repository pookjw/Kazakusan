import SwiftUI

struct SpinnerView: View {
    @ObservedObject private var observedViewModel: SpinnerObservedViewModel = .init()
    @StateObject private var stateViewModel: SpinnerViewStateViewModel = .init()
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: observedViewModel.lineWidth, antialiased: true)
                .foregroundColor(observedViewModel.unfilledColor)

            RadianShape(radians: $observedViewModel.radians, lineWidth: $observedViewModel.lineWidth)
                .clipped(antialiased: true)
                .foregroundColor(observedViewModel.filledColor)
                .rotationEffect(stateViewModel.isAnimating ? Angle(radians: CGFloat.pi * 2) : .zero)
                .animation(stateViewModel.isAnimating ? .easeInOut(duration: observedViewModel.duration).repeatForever(autoreverses: false) : .default, value: stateViewModel.isAnimating)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .onAppear {
            stateViewModel.isAnimating = true
        }
        .onDisappear {
            stateViewModel.isAnimating = false
        }
    }
    
    func lineWidth(_ lineWidth: CGFloat) -> SpinnerView {
        self.observedViewModel.lineWidth = lineWidth
        return self
    }
    
    func unfilledColor(_ unfilledColor: Color) -> SpinnerView {
        self.observedViewModel.unfilledColor = unfilledColor
        return self
    }
    
    func filledColor(_ filledColor: Color) -> SpinnerView {
        self.observedViewModel.filledColor = filledColor
        return self
    }
    
    func duration(_ duration: Double) -> SpinnerView {
        self.observedViewModel.duration = duration
        return self
    }
}

fileprivate struct RadianShape: Shape {
    @Binding var radians: Double
    @Binding var lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.midX, y: .zero))
            
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.midX,
                        startAngle: Angle(radians: (-CGFloat.pi / 2.0)),
                        endAngle: Angle(radians: (-CGFloat.pi / 2.0) + radians),
                        clockwise: false)
            
            path.addLine(to: CGPoint(x: (rect.midX) * (1.0 + sin(radians)) - Double(lineWidth) * sin(radians),
                                     y: (rect.midX) * (1.0 - cos(radians)) + Double(lineWidth) * cos(radians)))
            
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.midX - lineWidth,
                        startAngle: Angle(radians: (-CGFloat.pi / 2.0) + radians),
                        endAngle: Angle(radians: (-CGFloat.pi / 2.0)),
                        clockwise: true)
            
            path.addLine(to: CGPoint(x: rect.midX, y: .zero))
            
            path.closeSubpath()
        }
    }
}

#if DEBUG
struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpinnerView()
                .previewLayout(.fixed(width: 64.0, height: 64.0))
        }
    }
}
#endif
