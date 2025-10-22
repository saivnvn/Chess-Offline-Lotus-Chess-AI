//NAMTH - Trinh Hai Nam (Saivnvn): Just vibe-coded Lotus Chess with AI — one weekend, one dream.
import SwiftUI

// MARK: 🌸 Lớp chính - Hồ Sen Động (Lotus Pond Deluxe Edition)
final class LotusPondView {
    /// Hàm tĩnh để gọi view hồ sen
   // static func show(halfSpace: CGFloat, onInfoButtonTapped: @escaping () -> Void) -> some View {
       // LotusPondScene(halfSpace: halfSpace, onInfoButtonTapped: onInfoButtonTapped)
    //}
    
    static func show(halfSpace: CGFloat, lotusCount: Int, onInfoButtonTapped: @escaping () -> Void) -> some View {
        LotusPondScene(halfSpace: halfSpace, onInfoButtonTapped: onInfoButtonTapped, lotusCount: lotusCount)
    }

    // MARK: 🌊 View chính mô phỏng hồ sen
    private struct LotusPondScene: View {
        var halfSpace: CGFloat
        var onInfoButtonTapped: () -> Void
        
        var lotusCount: Int
        
        // ⚙️ Tham số cấu hình
        private let lotusSize: CGFloat = 50.0
        private let fishWidth: CGFloat = 50.0
        private let fishHeight: CGFloat = 50.0
        private let lotusMaxBobbingAmplitude: CGFloat = 20.0
        private let fishInitialDepthOffset: CGFloat = 5.0
        private let fishMaxVerticalAmplitude: CGFloat = 5.0
        private let numberOfFloatingLotuses = 1
        private let numberOfFish = 0
        
        @State private var floatingLotusConfigs: [FloatingLotusConfig] = []
        @State private var fishConfigs: [FishConfig] = []

        var body: some View {
            GeometryReader { geo in
                ZStack {
                    // 🌊 Gradient nền mặt nước
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.03, green: 0.13, blue: 0.18),
                            Color(red: 0.07, green: 0.27, blue: 0.35),
                            Color(red: 0.12, green: 0.45, blue: 0.55)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea()
                    
                    // 💫 Hiệu ứng ánh sáng phản chiếu chuyển động chậm
                    MovingLightReflection()
                        .blendMode(.screen)
                        .opacity(0.25)
                    
                    // 🌫️ Sóng động đa lớp
                    BeautifulWaveLayer(amplitude: 5, speed: 0.3, color: Color(red: 0.0, green: 0.1, blue: 0.15), opacity: 0.4, halfSpace: geo.size.height)
                        .blendMode(.multiply)
                        .offset(y: 15)
                    BeautifulWaveLayer(amplitude: 8, speed: 0.7, color: Color.cyan, opacity: 0.15, halfSpace: geo.size.height)
                        .offset(y: 10)
                        .blendMode(.overlay)
                    BeautifulWaveLayer(amplitude: 4, speed: 1.0, color: .white, opacity: 0.08, halfSpace: geo.size.height)
                        .blendMode(.screen)
                    BeautifulWaveLayer(amplitude: 2, speed: 0.15, color: Color(hue: 0.5, saturation: 0.7, brightness: 0.4), opacity: 0.3, halfSpace: geo.size.height)
                        .blendMode(.multiply)
                        .offset(y: 5)

                    // 🌸 Hoa sen trôi và phản chiếu
                    ForEach(floatingLotusConfigs.indices, id: \.self) { index in
                        FloatingLotus(
                            config: floatingLotusConfigs[index],
                            maxBobbingAmplitude: lotusMaxBobbingAmplitude,
                            viewWidth: geo.size.width
                        )
                        .frame(width: lotusSize, height: lotusSize)
                        .position(x: geo.size.width / 2, y: halfSpace * 0.3)
                        .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                    }

                    // 🐠 Cá bơi nhẹ nhàng
                    ForEach(fishConfigs.indices, id: \.self) { index in
                        FloatingFish(
                            config: fishConfigs[index],
                            viewWidth: geo.size.width,
                            initialDepthOffset: fishInitialDepthOffset,
                            maxVerticalAmplitude: fishMaxVerticalAmplitude
                        )
                        .frame(width: fishWidth, height: fishHeight)
                        .position(x: geo.size.width / 2, y: halfSpace * 0.5)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .onAppear {
                   // floatingLotusConfigs = (0..<numberOfFloatingLotuses).map { _ in FloatingLotusConfig() }
                    
                    floatingLotusConfigs = (0..<lotusCount).map { _ in FloatingLotusConfig() }
                    fishConfigs = (0..<numberOfFish).map { _ in FishConfig() }
                }
                .onChange(of: lotusCount) { newValue in
                    withAnimation(.easeInOut(duration: 1.0)) {
                        floatingLotusConfigs = (0..<newValue).map { _ in FloatingLotusConfig() }
                    }
                }
           
            }
          
            .frame(height: halfSpace)

            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        onInfoButtonTapped()
                    }) {
                        Image("thongtin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 39, height: 39)
                            .padding(.trailing, 20)
                    }
                    .buttonStyle(.plain)
                    .zIndex(9999999)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            )
        }
    }

    // MARK: - 🌸 Cấu hình & View cho Hoa Sen
    private struct FloatingLotusConfig {
        let id = UUID()
        let bobbingDuration: Double = 5.0
        let rotationEffect: Double = Double.random(in: -5...5)
        let travelDuration: Double
        let startFromLeft: Bool = Bool.random()

        init() {
            self.travelDuration = Double.random(in: 40...55)
        }
    }

    private struct FloatingLotus: View {
        let config: FloatingLotusConfig
        let maxBobbingAmplitude: CGFloat
        let viewWidth: CGFloat
        @State private var bobbingOffset: CGFloat = 0
        @State private var horizontalOffset: CGFloat = 0

        var body: some View {
            ZStack {
                // 🌸 Bông hoa chính
                Image("lotus_flower")
                    .resizable()
                    .scaledToFit()
                    .opacity(Double.random(in: 0.85...1.0))
                    .rotationEffect(.degrees(config.rotationEffect))
                    .offset(x: horizontalOffset, y: bobbingOffset)
                    .onAppear {
                        startBobbingAnimation()
                        startHorizontalDrift()
                    }
                
                // 🌊 Phản chiếu dưới mặt nước
                Image("conca")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(y: -1)
                    .opacity(0.25)
                    .blur(radius: 1)
                    .offset(x: horizontalOffset, y: bobbingOffset + 40)
            }
        }
        
        private func startHorizontalDrift() {
            let offScreenPadding: CGFloat = 50
            let travelRange = (viewWidth / 2) + offScreenPadding
            let startX = config.startFromLeft ? -travelRange : travelRange
            let endX = -startX
            horizontalOffset = startX

            withAnimation(.linear(duration: config.travelDuration).repeatForever(autoreverses: true)) {
                horizontalOffset = endX
            }
        }
        
        private func startBobbingAnimation() {
            withAnimation(.linear(duration: config.bobbingDuration).repeatForever(autoreverses: true)) {
                bobbingOffset = maxBobbingAmplitude
            }
        }
    }

    // MARK: - 🐠 Cấu hình & View cho Cá
    private struct FishConfig {
        let id = UUID()
        let travelDuration: Double = Double.random(in: 20...30)
        let verticalBobbingDuration: Double = Double.random(in: 6...12)
    }

    private struct FloatingFish: View {
        let config: FishConfig
        let viewWidth: CGFloat
        let initialDepthOffset: CGFloat
        let maxVerticalAmplitude: CGFloat
        
        @State private var horizontalOffset: CGFloat = 0
        @State private var verticalOffset: CGFloat = 0

        var body: some View {
            Image("conca")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .offset(x: horizontalOffset, y: initialDepthOffset + verticalOffset)
                .opacity(Double(max(0.2, 1 - abs(horizontalOffset) / (viewWidth * 0.9))))
                .onAppear {
                    initializeAndStartMovement()
                }
        }

        private func initializeAndStartMovement() {
            let offScreenPadding: CGFloat = 50
            let startX = viewWidth / 2 + offScreenPadding
            let endX = -viewWidth / 2 - offScreenPadding
            horizontalOffset = startX
            
            func animateCycle() {
                withAnimation(.linear(duration: config.travelDuration)) {
                    horizontalOffset = endX
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + config.travelDuration) {
                    horizontalOffset = startX
                    animateCycle()
                }
            }
            animateCycle()
            withAnimation(.easeInOut(duration: config.verticalBobbingDuration).repeatForever(autoreverses: true)) {
                verticalOffset = -maxVerticalAmplitude
            }
        }
    }

    // MARK: 🌊 Sóng nước Canvas động
    private struct BeautifulWaveLayer: View {
        let amplitude: CGFloat
        let speed: Double
        let color: Color
        let opacity: Double
        let halfSpace: CGFloat

        var body: some View {
            TimelineView(.animation(minimumInterval: 1/60, paused: false)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let phase = CGFloat(time * speed).truncatingRemainder(dividingBy: 2 * .pi)
                    let baseHeight = halfSpace * 0.5

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: baseHeight))
                    for x in stride(from: 0, through: size.width, by: 4) {
                        let y = sin((x / size.width) * 4 * .pi + phase) * amplitude
                        path.addLine(to: CGPoint(x: x, y: baseHeight + y))
                    }
                    path.addLine(to: CGPoint(x: size.width, y: halfSpace))
                    path.addLine(to: CGPoint(x: 0, y: halfSpace))
                    path.closeSubpath()
                    context.fill(path, with: .color(color.opacity(opacity)))
                }
            }
        }
    }

    // MARK: ✨ Hiệu ứng ánh sáng chuyển động
    private struct MovingLightReflection: View {
        @State private var move = false
        var body: some View {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(10))
            .offset(x: move ? 300 : -300)
            .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: move)
            .onAppear { move = true }
        }
    }
}
