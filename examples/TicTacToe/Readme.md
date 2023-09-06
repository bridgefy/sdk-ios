
# Bridgefy SDK Example Project

This example project demonstrates how to integrate and use the Bridgefy SDK in a Swift-based iOS application. The Bridgefy SDK allows developers to enable offline communication and data transfer using Bluetooth Low Energy (BLE) mesh networks.

## Description

The example application in this repository showcases how to:

- Set up the Bridgefy SDK in your project.
- Initialize and start using the SDK.
- Send and receive data through the Bridgefy network.

## Installation

To use the Bridgefy SDK in your project, follow these steps:

1. Clone this repository to your local machine.

2. Open the project in Xcode.

3. Follow the installation instructions provided in the official Bridgefy SDK documentation to integrate the library into your project.

   https://github.com/bridgefy/sdk-ios

4. Ensure you've configured the necessary permissions in your project's `Info.plist` file, as described in the Bridgefy documentation.

5. Run the application on a Bluetooth Low Energy (BLE)-compatible device.

## Configuration

To set up and use the Bridgefy SDK in your application, follow these steps:

1. Initialize the Bridgefy SDK in your app with your API key and a delegate that implements the required methods.

   ```swift
   import BridgefySDK

   // Initialize the SDK
   do {
       bridgefy = try Bridgefy(withApiKey: "YOUR_API_KEY", delegate: self, verboseLogging: true)
   } catch {
       // Handle the error
   }
