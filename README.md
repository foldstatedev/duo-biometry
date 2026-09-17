# BiometryCheck

A tiny SwiftUI app that asks the device which biometric hardware it actually has,
instead of assuming Face ID. It exists because the iPhone Duo ships Touch ID, so
apps that hardcoded Face ID now show real users the wrong icon and wrong wording.

## The fast answer

Do not hardcode the biometric type. Ask `LAContext`, and call
`canEvaluatePolicy(_:error:)` before you read `biometryType`.

```swift
import LocalAuthentication

let context = LAContext()
var error: NSError?
let available = context.canEvaluatePolicy(
    .deviceOwnerAuthenticationWithBiometrics,
    error: &error
)

switch context.biometryType {
case .faceID:
    print("Face ID")
case .touchID:
    print("Touch ID")
case .opticID:
    print("Optic ID")
case .none:
    print("No biometrics")
@unknown default:
    print("Unrecognised")
}

if !available {
    print("Unavailable: \(error?.localizedDescription ?? "unknown")")
}
```

The two calls answer different questions and you need both:

* `biometryType` tells you which hardware exists.
* `canEvaluatePolicy` tells you whether it is usable right now, and its `error`
  says why not (nothing enrolled, locked out, no passcode set).

A device can report `.faceID` while `canEvaluatePolicy` returns `false` because
nothing is enrolled. Read only one and your UI will offer an unlock that cannot work.

### Why the ordering matters

Apple's documentation for `biometryType` is explicit: the property is set only
after `canEvaluatePolicy(_:error:)` has been called, it is set regardless of what
that call returns, and it defaults to `.none`. Read it first and a Face ID device
reports `.none`, so your UI quietly claims the hardware is not there.

The SDK header comment is shorter and states none of this. The full contract is on
the documentation page:
<https://developer.apple.com/documentation/localauthentication/lacontext/biometrytype>

### What the simulator does, and why to ignore it

Measured on iOS 27 simulators, `biometryType` already returned the right value
before the call (raw values per `LAPublicDefines.h`: none 0, touchID 1, faceID 2,
opticID 4):

| Simulator           | before | canEvaluatePolicy | after |
| ------------------- | ------ | ----------------- | ----- |
| iPhone SE (3rd gen) | 1      | true              | 1     |
| iPhone 18 Pro       | 2      | true              | 2     |

The simulator is more permissive than the documented contract. Code that reads
`biometryType` first will pass here and can still report `.none` on real hardware.
Follow the documented ordering, not what the simulator lets you get away with.

## NaiveView.swift is wrong on purpose

`NaiveView.swift` is the anti-pattern, kept so the two can sit side by side. It
hardcodes the `faceid` SF Symbol, the string "Use Face ID to unlock", and a
"Face ID is not set up" error state, and it never touches `LAContext` at all.

On an iPhone 18 Pro it looks perfect. On an iPhone SE it confidently lies. That is
the whole point: the bug is invisible on the device you developed against.

Do not copy it. `ContentView.swift` is the correct version.

## Run it

Requires Xcode 27 (deployment target iOS 27).

```bash
open BiometryCheck.xcodeproj
```

Run it on two simulators to see the difference:

* **iPhone SE (3rd generation)** reports Touch ID
* **iPhone 18 Pro** reports Face ID

Enrol a biometric first, or `canEvaluatePolicy` returns `false` and you will see
the not-enrolled message instead of the ready state. Enrolment lives in the
Simulator's Features menu, under Face ID or Touch ID, as the Enrolled toggle.

The Xcode preview in either Swift file renders both screens side by side at iPhone
SE size. Set the canvas device picker to iPhone SE (3rd generation), or
`ContentView` reports the canvas device and both panels agree, proving nothing.

## LABiometryType is an open enum

`LABiometryType` is an Objective-C `NS_ENUM`, which Swift imports as non-frozen.
A switch listing all four cases without `@unknown default` compiles, but warns:

```
switch covers known cases, but 'LABiometryType' may have additional unknown
values, possibly added in future versions; this is an error in the Swift 6
language mode
```

So `@unknown default` is not optional hygiene. Leave it out and the code breaks
in the Swift 6 language mode. `.opticID` is marked `ios(17.0)` in the SDK, so it
needs no availability guard at any modern deployment target.

## Licence

MIT. See [LICENSE](LICENSE).
