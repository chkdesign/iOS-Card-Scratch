import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.00, green: 0.03, blue: 0.16),
                    Color(red: 0.00, green: 0.01, blue: 0.12),
                    Color(red: 0.00, green: 0.00, blue: 0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    Color(red: 0.02, green: 0.72, blue: 0.77, opacity: 0.65),
                    Color(red: 0.02, green: 0.72, blue: 0.77, opacity: 0.0)
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 520
            )

            RadialGradient(
                colors: [
                    Color(red: 0.78, green: 0.86, blue: 0.15, opacity: 0.20),
                    Color(red: 0.78, green: 0.86, blue: 0.15, opacity: 0.0)
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }
}

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
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.95),
                        Color(red: 0.67, green: 0.90, blue: 1.0, opacity: 0.95),
                        Color(red: 0.07, green: 0.72, blue: 0.97, opacity: 0.95)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: size.height)
                )
            )

            context.draw(
                Text("SCRATCH TO REVEAL")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.10, green: 0.34, blue: 0.46, opacity: 0.5)),
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
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color(red: 0.00, green: 0.733, blue: 1.00, opacity: 0.70)
                        ],
                        startPoint: UnitPoint(x: 0.18, y: 0.20),
                        endPoint: UnitPoint(x: 0.82, y: 0.92)
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 0.44, green: 0.66, blue: 0.74, opacity: 0.50),
                            Color(red: 0.18, green: 0.28, blue: 0.43, opacity: 0.75),
                            Color(red: 0.05, green: 0.37, blue: 0.56, opacity: 0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text("Pre Match Picks completed")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.52))
                    .padding(.top, 26)

                VStack(alignment: .leading, spacing: -6) {
                    Text("Pre match is")
                    Text("theory.")
                    Text("Live is proof.")
                    Text("Now we")
                        .foregroundStyle(Color.white.opacity(0.38))
                    Text("play live")
                        .foregroundStyle(Color.white.opacity(0.38))
                }
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .kerning(0.8)
                .foregroundStyle(Color.white.opacity(0.9))
                .padding(.top, 30)

                Spacer()

                HStack(spacing: 12) {
                    AvatarBadgeView()
                    Text("You vs everyone")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct AvatarBadgeView: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.11, green: 0.78, blue: 1.0),
                        Color(red: 0.02, green: 0.18, blue: 0.30)
                    ],
                    center: .topTrailing,
                    startRadius: 2,
                    endRadius: 18
                )
            )
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.7))
            )
            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
    }
}
