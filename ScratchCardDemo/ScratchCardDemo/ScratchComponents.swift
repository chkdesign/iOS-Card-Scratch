import SwiftUI

struct TogglePill: View {
    let onIcon: String
    let offIcon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isOn ? onIcon : offIcon)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
            }
            .foregroundColor(isOn ? .black : .white.opacity(0.45))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(
                    isOn ? Color.white.opacity(0.90) : Color.white.opacity(0.10)
                )
            )
        }
    }
}

struct ScratchOverlayView: View {
    let points: [CGPoint]
    let brushRadius: CGFloat
    let cursorPosition: CGPoint?
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.875, green: 0.866, blue: 0.838))
            )

            context.draw(
                Text("SCRATCH TO REVEAL")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.58)),
                at: CGPoint(x: size.width / 2, y: size.height / 2),
                anchor: .center
            )

            context.blendMode = .clear
            for point in points {
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: point.x - brushRadius,
                            y: point.y - brushRadius,
                            width: brushRadius * 2,
                            height: brushRadius * 2
                        )
                    ),
                    with: .color(.black)
                )
            }

            if let c = cursorPosition {
                context.blendMode = .normal
                context.stroke(
                    Path(
                        ellipseIn: CGRect(
                            x: c.x - brushRadius,
                            y: c.y - brushRadius,
                            width: brushRadius * 2,
                            height: brushRadius * 2
                        )
                    ),
                    with: .color(.white.opacity(0.6)),
                    lineWidth: 1.5
                )
            }
        }
        .drawingGroup()
    }
}

struct RewardCardView: View {
    var body: some View {
        ZStack {
            Color(red: 0.29, green: 0.95, blue: 0.18)

            VStack {
                HStack {
                    CornerPlusButton()
                    Spacer()
                    CornerPlusButton()
                }
                Spacer()
                HStack {
                    CornerPlusButton()
                    Spacer()
                    CornerPlusButton()
                }
            }
            .padding(20)

            VStack(spacing: 6) {
                Text("You won!")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
                Text("$100 GIFT CARD")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(.black.opacity(0.75))
                Text("Tap reset and scratch again")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.55))
                    .padding(.top, 8)
            }
        }
    }
}

private struct CornerPlusButton: View {
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: 24, height: 24)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
            )
    }
}
