import LocalAuthentication
import SwiftUI

/// What `LAContext` reports about the biometric hardware on this device.
struct BiometryReport {
    let title: String
    let detail: String
    let symbolName: String
    let tint: Color

    /// `LAContext.biometryType` is only populated once `canEvaluatePolicy(_:error:)`
    /// has run, so the policy check always happens first — including when it fails.
    /// A failing check still tells us the hardware type, just that it is unusable
    /// right now (for example, biometrics are supported but nothing is enrolled).
    static func read() -> BiometryReport {
        let context = LAContext()
        var policyError: NSError?
        let canUseBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &policyError
        )

        let detail: String
        if canUseBiometrics {
            detail = "Enrolled and ready to use."
        } else {
            detail = policyError?.localizedDescription ?? "Biometric authentication is unavailable."
        }

        switch context.biometryType {
        case .faceID:
            return BiometryReport(title: "Face ID", detail: detail, symbolName: "faceid", tint: .blue)
        case .touchID:
            return BiometryReport(title: "Touch ID", detail: detail, symbolName: "touchid", tint: .pink)
        case .opticID:
            return BiometryReport(title: "Optic ID", detail: detail, symbolName: "opticid", tint: .purple)
        case .none:
            return BiometryReport(
                title: "No Biometrics",
                detail: detail,
                symbolName: "xmark.shield",
                tint: .orange
            )
        @unknown default:
            return BiometryReport(
                title: "Unrecognised",
                detail: detail,
                symbolName: "questionmark.circle",
                tint: .gray
            )
        }
    }
}

struct ContentView: View {
    @State private var report = BiometryReport.read()

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: report.symbolName)
                .font(.system(size: 110, weight: .light))
                .foregroundStyle(report.tint)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("This device uses")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text(report.title)
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(report.tint)
            }

            Text(report.detail)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Check Again") {
                report = BiometryReport.read()
            }
            .font(.title3.weight(.semibold))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
    }
}

#Preview {
    ContentView()
}
