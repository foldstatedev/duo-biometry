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

/// Renders the anti-pattern and the correct version next to each other at
/// iPhone SE (3rd generation) screen size, for screen recording.
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

    var body: some View {
        HStack(spacing: 24) {
            panel("Naive — hardcoded", tint: .red) {
                NaiveView()
            }
            panel("Correct — biometryType", tint: .green) {
                ContentView()
            }
        }
        .padding(24)
    }

    private func panel<Content: View>(
        _ caption: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 12) {
            Text(caption)
                .font(.headline)
                .foregroundStyle(tint)

            content()
                .frame(width: Self.seScreen.width, height: Self.seScreen.height)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(tint.opacity(0.7), lineWidth: 3)
                }
        }
    }
}

#Preview("Naive vs Correct — iPhone SE", traits: .fixedLayout(width: 830, height: 760)) {
    BiometryComparison()
}
