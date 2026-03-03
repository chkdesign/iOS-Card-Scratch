import SwiftUI

struct ScratchCardView: View {
    @StateObject private var feedback = ScratchFeedbackManager()
    @State private var scratchPath: [CGPoint] = []
    @State private var isRevealed = false
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var showConfetti = false
    @State private var cursorPosition: CGPoint? = nil

    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 440
    private let brushRadius: CGFloat = 36

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.22, blue: 0.26),
                    Color(red: 0.10, green: 0.13, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Spacer()
                    TogglePill(
                        onIcon: "speaker.wave.2.fill",
                        offIcon: "speaker.slash.fill",
                        label: "Sound",
                        isOn: $feedback.isSoundEnabled
                    )
                    TogglePill(
                        onIcon: "hand.tap.fill",
                        offIcon: "hand.tap",
                        label: "Haptics",
                        isOn: $feedback.isHapticsEnabled
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)

                Spacer()

                ZStack {
                    RewardCardView()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 24))

                    if !isRevealed {
                        ScratchOverlayView(
                            points: scratchPath,
                            brushRadius: brushRadius,
                            cursorPosition: cursorPosition,
                            size: CGSize(width: cardWidth, height: cardHeight)
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .gesture(scratchGesture)
                    }

                    if showConfetti {
                        ConfettiView(pieces: confettiPieces)
                            .frame(width: cardWidth, height: cardHeight)
                            .allowsHitTesting(false)
                    }
                }
                .shadow(color: .black.opacity(0.4), radius: 24, y: 12)

                Group {
                    if isRevealed {
                        Button(action: resetCard) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("SCRATCH AGAIN")
                                    .font(.system(size: 13, weight: .semibold))
                                    .tracking(2)
                            }
                            .foregroundColor(.black.opacity(0.75))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 15)
                            .background(Capsule().fill(Color.white.opacity(0.88)))
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        Text("SCRATCH TO REVEAL")
                            .font(.system(size: 12, weight: .medium))
                            .tracking(3)
                            .foregroundColor(.white.opacity(0.4))
                            .transition(.opacity)
                    }
                }
                .padding(.top, 32)

                Spacer()
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isRevealed)
    }

    private var scratchGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                cursorPosition = value.location
                scratchPath.append(value.location)
                feedback.startScratchSound()
                feedback.scratchHaptic()
                checkRevealThreshold()
            }
            .onEnded { _ in
                cursorPosition = nil
                feedback.stopScratchSound()
                checkRevealThreshold()
            }
    }

    private func checkRevealThreshold() {
        guard !isRevealed, coveredArea() >= 0.45 else { return }
        feedback.stopScratchSound()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
            isRevealed = true
        }
        feedback.playWinSound()
        feedback.winHaptic()
        triggerConfetti()
    }

    private func coveredArea() -> CGFloat {
        let cell: CGFloat = 16
        var cells = Set<String>()
        let cols = Int(cardWidth / cell)
        let rows = Int(cardHeight / cell)
        let radiusCells = Int(ceil(brushRadius / cell)) + 1

        for point in scratchPath {
            let cx = Int(point.x / cell)
            let cy = Int(point.y / cell)
            for dx in -radiusCells...radiusCells {
                for dy in -radiusCells...radiusCells {
                    let x = cx + dx
                    let y = cy + dy
                    if x >= 0 && x < cols && y >= 0 && y < rows {
                        cells.insert("\(x),\(y)")
                    }
                }
            }
        }

        return CGFloat(cells.count) / CGFloat(cols * rows)
    }

    private func triggerConfetti() {
        confettiPieces = (0..<60).map { _ in
            ConfettiPiece.random(in: CGSize(width: cardWidth, height: cardHeight))
        }
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConfetti = false
        }
    }

    private func resetCard() {
        feedback.tapHaptic()
        withAnimation {
            isRevealed = false
            showConfetti = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            scratchPath = []
            confettiPieces = []
        }
    }
}
