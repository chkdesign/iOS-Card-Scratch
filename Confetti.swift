import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let yStart: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
    let xDrift: CGFloat
    let duration: Double
    let delay: Double

    static func random(in size: CGSize) -> ConfettiPiece {
        let palette: [Color] = [.yellow, .orange, .pink, .mint, .cyan, .white]
        return ConfettiPiece(
            x: .random(in: 0...size.width),
            yStart: .random(in: -40...0),
            size: .random(in: 6...12),
            color: palette.randomElement() ?? .white,
            rotation: .random(in: 0...360),
            xDrift: .random(in: -40...40),
            duration: .random(in: 1.8...2.9),
            delay: .random(in: 0...0.35)
        )
    }
}

struct ConfettiView: View {
    let pieces: [ConfettiPiece]
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 1.4)
                        .rotationEffect(.degrees(animate ? piece.rotation + 380 : piece.rotation))
                        .position(
                            x: animate ? piece.x + piece.xDrift : piece.x,
                            y: animate ? geo.size.height + 30 : piece.yStart
                        )
                        .opacity(animate ? 0.0 : 1.0)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
            .clipped()
            .onAppear {
                animate = false
                DispatchQueue.main.async {
                    animate = true
                }
            }
        }
    }
}
