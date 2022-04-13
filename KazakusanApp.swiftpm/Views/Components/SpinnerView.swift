import SwiftUI

struct SpinnerView: View {
    @ObservedObject private var viewModel: SpinnerViewModel = .init()
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: viewModel.lineWidth, antialiased: true)
                .foregroundColor(viewModel.unfilledColor)
            
            RadianShape(radians: $viewModel.radians, lineWidth: $viewModel.lineWidth)
                .clipped(antialiased: true)
                .foregroundColor(viewModel.filledColor)
                .onAppear { viewModel.isAnimating = true }
                .onDisappear { viewModel.isAnimating = false }
        }
        .rotationEffect(Angle(radians: viewModel.isAnimating ? (CGFloat.pi * 2) : (.zero)))
        .animation(viewModel.isAnimating ? .linear(duration: viewModel.duration).repeatForever(autoreverses: false) : nil, value: viewModel.isAnimating)
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    func lineWidth(_ lineWidth: CGFloat) -> SpinnerView {
        self.viewModel.lineWidth = lineWidth
        return self
    }
    
    func unfilledColor(_ unfilledColor: Color) -> SpinnerView {
        self.viewModel.unfilledColor = unfilledColor
        return self
    }
    
    func filledColor(_ filledColor: Color) -> SpinnerView {
        self.viewModel.filledColor = filledColor
        return self
    }
    
    func duration(_ duration: Double) -> SpinnerView {
        self.viewModel.duration = duration
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
