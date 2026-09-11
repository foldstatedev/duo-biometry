//  ⚠️ ANTI-PATTERN — DO NOT COPY THIS FILE.
//
//  This is the "before" example for the video: it assumes every device has
//  Face ID. The icon, the prompt and the error are all hardcoded string
//  literals, and there is no LAContext anywhere, so this screen lies on any
//  Touch ID or Optic ID device. ContentView.swift is the correct version —
//  it asks LAContext what the hardware actually is. Use that one.

import SwiftUI
import UIKit

struct NaiveView: View {
    /// Faked so the wrong error state can be shown on camera. The real version
    /// gets this from `canEvaluatePolicy(_:error:)` instead of a local Bool.
    @State private var isEnrolled = true

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "faceid")
                .font(.system(size: 110, weight: .light))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("This device uses")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Face ID")
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.blue)
            }

            Text(isEnrolled ? "Use Face ID to unlock" : "Face ID is not set up")
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            // Checks nothing at all — it just flips the hardcoded state.
            Button("Check Again") {
                isEnrolled.toggle()
            }
            .font(.title3.weight(.semibold))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
    }
}

// MARK: - Preview comparison

/// Renders the anti-pattern and the correct version next to each other as
/// two iPhone SE (3rd generation) screens, scaled down to fit whatever space
/// the canvas gives it, for screen recording.
///
/// The pair is laid out at full size (two 375 × 667 screens) and then shrunk
/// with `scaleEffect`, so both panels stay exactly the same size as each other
/// and keep true SE proportions rather than being re-laid-out at a smaller
/// width — the inner views are designed for 375pt and would clip internally.
/// The labels and borders divide by the scale factor so they render at a
/// constant point size, staying legible however far the screens shrink.
///
/// Both NaiveView.swift and ContentView.swift preview this same view, so
/// whichever file is open, the canvas shows the identical comparison.
///
/// Set the canvas device picker to **iPhone SE (3rd generation)**. The frames
/// below fix the geometry, but `ContentView` asks LAContext what the hardware
/// is, and that answer comes from the canvas device — on a Face ID device both
/// panels agree and the comparison proves nothing. There is no API to pin the
/// preview device in code: `previewDevice(_:)` is deprecated as of 27.0 and
/// tells you to use the canvas picker, and no device PreviewTrait exists.
struct BiometryComparison: View {
    /// iPhone SE (3rd generation) logical screen size, in points (750 × 1334 @2x).
    static let seScreen = CGSize(width: 375, height: 667)

    private static let gap: CGFloat = 24
    private static let margin: CGFloat = 24

    /// Width of the pair before scaling: two SE screens, the gap between them,
    /// and the margin on each side. Deterministic, so it can drive the scale.
    private static let naturalWidth = seScreen.width * 2 + gap + margin * 2

    var body: some View {
        GeometryReader { proxy in
            // Shrink to fit the width we are given; never enlarge past 1:1.
            // Floored so a transient zero-width layout pass cannot divide by zero.
            let scale = max(min(proxy.size.width / Self.naturalWidth, 1), 0.05)

            pair(scale: scale)
                .frame(width: Self.naturalWidth)
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func pair(scale: CGFloat) -> some View {
        HStack(spacing: Self.gap) {
            panel("Naive — hardcoded", tint: .red, scale: scale) {
                NaiveView()
            }
            panel("Correct — biometryType", tint: .green, scale: scale) {
                ContentView()
            }
        }
        .padding(Self.margin)
    }

    private func panel<Content: View>(
        _ caption: String,
        tint: Color,
        scale: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 12 / scale) {
            // Sized so the longer caption fits the panel width once scaled;
            // the shrink factor is a guard against Dynamic Type pushing it over.
            Text(caption)
                .font(.system(size: 14 / scale, weight: .semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(width: Self.seScreen.width)

            content()
                .frame(width: Self.seScreen.width, height: Self.seScreen.height)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(tint.opacity(0.7), lineWidth: 3 / scale)
                }
        }
    }
}

#Preview("Naive vs Correct — iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    BiometryComparison()
}
