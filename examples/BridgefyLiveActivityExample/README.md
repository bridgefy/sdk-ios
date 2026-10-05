# Bridgefy SDK – Live Activity Example

This example app shows how the Bridgefy SDK keeps running **in the background** by using a **Live Activity**.

Starting on iOS 26, the SDK can start a Live Activity to keep foreground-equivalent Bluetooth scanning privileges while your app is in the background. Without it, `CBCentralManager` is subject to the usual iOS background scanning restrictions. This project demonstrates the minimum setup needed to see that behavior working end to end.

## What this example demonstrates

- Initializing the SDK and starting it with `supportsBackgroundScanning: true`.
- The Live Activity that the SDK starts automatically when that flag is enabled.
- A Widget Extension that renders the Live Activity (lock screen and Dynamic Island) using `BLEActivityAttributes`.
- The Live Activity delegate callbacks (`bridgefyDidStartLiveActivity`, `bridgefyDidDismissLiveActivity`, `bridgefyDidFailToStartLiveActivity`).
- Restarting the Live Activity after the user dismisses it.

## Requirements

- Xcode 26 or later
- A **physical device running iOS 26 or later** (Bluetooth does not work in the simulator)
- A valid Bridgefy **API key**
- An Internet connection the first time the app runs, to validate the license
- A second device running the SDK to see the connected devices counter change

> On iOS 18 and earlier, `supportsBackgroundScanning` has no effect and standard background scanning restrictions apply.

## Before you run it

You **must** change the following values to your own, otherwise the project will not build or run.

### 1. Set your API key

Open `ContentView.swift` and replace the placeholder with your Bridgefy API key:

```swift
bridgefy = try Bridgefy(withApiKey: "YOUR_API_KEY",
                        delegate: self,
                        verboseLogging: true)
```

Do not commit your real API key to a public repository.

### 2. Change the bundle identifier of the app

1. Select the project in Xcode, then the **app target**.
2. Go to **Signing & Capabilities**.
3. Set a unique **Bundle Identifier** (for example `com.yourcompany.BridgefyLiveActivityExample`).
4. Select your own **Team**.

### 3. Change the bundle identifier of the widget

1. Select the **Widget Extension target** (`LiveActivityWidget`).
2. Go to **Signing & Capabilities**.
3. Set the **Bundle Identifier** so that it **starts with the app's bundle identifier**, for example:

```
App:    com.yourcompany.BridgefyLiveActivityExample
Widget: com.yourcompany.BridgefyLiveActivityExample.LiveActivityWidget
```

If the widget's bundle identifier is not prefixed with the app's, Xcode fails with:

```
error: Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier.
```

Make sure to update it for both the **Debug** and **Release** configurations, and select your Team on the widget target as well.

## Project setup checklist

These are already configured in the example. If you reuse this setup in your own app, you need to do the same:

1. **Add the SDK** through Swift Package Manager (`https://github.com/bridgefy/sdk-ios`) and link `BridgefySDK` to **both** the app target and the Widget Extension target.
2. **Enable the Live Activities capability** in the app target.
3. **Add `NSSupportsLiveActivities = YES`** to the app's `Info.plist`.
4. **Add the Bluetooth usage descriptions** to the app's `Info.plist` (see the [Permissions](https://github.com/bridgefy/sdk-ios#permissions) section of the SDK documentation).
5. **Provide a Widget Extension** that declares an `ActivityConfiguration<BLEActivityAttributes>`.
6. Set the deployment target of the app and the widget to **iOS 26** (or use `@available(iOS 26, *)` checks).

## How to run

1. Open `BridgefyLiveActivityExample.xcodeproj`.
2. Complete the steps in **Before you run it**.
3. Select a physical device running iOS 26+ and run the app.
4. Allow the Bluetooth permission and make sure Live Activities are enabled for the app in **Settings**.
5. Tap **Start**. The SDK starts and launches the Live Activity automatically.
6. Send the app to the background or lock the device. The Live Activity stays visible on the lock screen and Dynamic Island while the SDK keeps scanning.
7. Run the SDK on a second device to see the `connectedDevices` counter update. The SDK updates this value on its own; you don't need to call `Activity.update`.

If you dismiss the Live Activity, the app is notified through `bridgefyDidDismissLiveActivity()` and you can bring it back with the **Restart Live Activity** button.

## Key code

Starting the SDK with background support:

```swift
bridgefy.start(withUserId: nil,
               andPropagationProfile: .standard,
               supportsBackgroundScanning: true)
```

Restarting the Live Activity and checking its status (iOS 26+):

```swift
if #available(iOS 26, *) {
    bridgefy.restartLiveActivity()
    let isActive = bridgefy.isLiveActivityActive
}
```

Rendering the Live Activity in the Widget Extension:

```swift
ActivityConfiguration(for: BLEActivityAttributes.self) { context in
    Text("\(context.state.connectedDevices) connected devices")
} dynamicIsland: { context in
    // Dynamic Island UI
}
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier` | The widget's bundle ID must start with the app's bundle ID. See [step 3](#3-change-the-bundle-identifier-of-the-widget). |
| The Live Activity does not appear | Check that you are on a physical device with iOS 26+, that `NSSupportsLiveActivities` is `YES`, that the Live Activities capability is enabled, and that Live Activities are allowed in Settings. |
| `bridgefyDidFailToStartLiveActivity` is called | Read the error it returns; it is the underlying ActivityKit error (for example `ActivityAuthorizationError`). |
| The SDK fails to start | Verify that your API key is valid and that the device has Internet access on the first run. |
| No peers are detected | Make sure Bluetooth is on, permissions were granted, and a second device is running the SDK nearby. |

## More information

- [Bridgefy SDK documentation](https://github.com/bridgefy/sdk-ios)
- [ActivityKit](https://developer.apple.com/documentation/ActivityKit)
- [WidgetKit](https://developer.apple.com/documentation/WidgetKit)
- Support: contact@bridgefy.me
