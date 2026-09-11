//  ⚠️ ANTI-PATTERN — DO NOT COPY THIS FILE.
//
//  This is the "before" example for the video: it assumes every device has
//  Face ID. The icon, the prompt and the error are all hardcoded string
//  literals, and there is no LAContext anywhere, so this screen lies on any
//  Touch ID or Optic ID device. ContentView.swift is the correct version —
//  it asks LAContext what the hardware actually is. Use that one.

import SwiftUI

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

#Preview {
    NaiveView()
}
