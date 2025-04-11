# Chanel RFID Example App

This is an example iOS application that demonstrates how to use the ChanelRFIDPlugin to interact with Chanel RFID readers via Bluetooth Low Energy (BLE).

## Features

- Discover and list Chanel RFID readers
- Connect to specific RFID devices
- Start and stop RFID scanning
- Display scanned RFID tags
- Reset connected devices
- Comprehensive error handling

## Requirements

- iOS 14.0+
- Xcode 13.0+
- CocoaPods

## Installation

1. Clone this repository
2. Navigate to the project directory
3. Run `pod install` to install dependencies
4. Open `ChanelRFIDExample.xcworkspace` in Xcode
5. Build and run the app on a physical iOS device (BLE is not available in the simulator)

## Usage

1. Launch the app
2. The app will automatically start searching for Chanel RFID readers
3. Tap on a discovered device to connect to it
4. Once connected, use the "Start Scan" button to begin scanning for RFID tags
5. Scanned tags will appear at the bottom of the screen
6. Use the "Stop Scan" button to stop scanning
7. Use the "Disconnect" button to disconnect from the device
8. Use the "Reset Device" button to reset the connected RFID reader

## Permissions

The app requires Bluetooth permissions to function. These are already configured in the Info.plist file:

- NSBluetoothAlwaysUsageDescription
- NSBluetoothPeripheralUsageDescription

## Project Structure

- `AppDelegate.swift` & `SceneDelegate.swift`: Standard iOS app delegates
- `ViewController.swift`: Main UI and interaction logic
- `Main.storyboard` & `LaunchScreen.storyboard`: UI layout
- `Info.plist`: App configuration including required permissions
- `Podfile`: CocoaPods dependencies

## License

This example app is available under the MIT license. See the LICENSE file for more info.
