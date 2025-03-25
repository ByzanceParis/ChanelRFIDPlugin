# ChanelRFIDPlugin Documentation

## Overview

The ChanelRFIDPlugin is an iOS plugin designed to interact with Channel RFID readers via Bluetooth Low Energy (BLE). This plugin provides a simple interface for discovering, connecting, and communicating with RFID devices.

## Installation

### CocoaPods
Add the following to your Podfile:
```ruby
pod 'ChanelRFIDPlugin'
```

### Swift Package Manager
Add the package in Xcode:
1. Go to File > Swift Packages > Add Package Dependency
2. Enter the repository URL for the ChanelRFIDPlugin

## Usage

### Import the Plugin
```swift
import ChanelRFIDPlugin
```

### Initialization
```swift
let rfidManager = ChanelRFIDPlugin()
```

## Methods

### `listDevices()`
Discovers and lists all BLE devices with "byzance" in their name.

```swift
rfidManager.listDevices { devices, error in
    if let error = error {
        print("Error discovering devices: \(error.localizedDescription)")
        return
    }
    
    devices.forEach { device in
        print("Found device: \(device.name)")
    }
}
```

### `connect(to device: BLEDevice)`
Connects to a specific Channel RFID device.

```swift
rfidManager.connect(to: selectedDevice) { success, error in
    if let error = error {
        print("Connection failed: \(error.localizedDescription)")
        return
    }
    
    if success {
        print("Successfully connected to device")
    }
}
```

### `startScan()`
Begins listening for RFID scans on the connected device.

```swift
rfidManager.startScan { rfidTag, error in
    if let error = error {
        print("Scan error: \(error.localizedDescription)")
        return
    }
    
    if let tag = rfidTag {
        print("Scanned RFID Tag: \(tag)")
    }
}
```

### `stopScan()`
Stops listening for RFID scans.

```swift
rfidManager.stopScan { success, error in
    if let error = error {
        print("Stop scan error: \(error.localizedDescription)")
        return
    }
    
    if success {
        print("Scanning stopped successfully")
    }
}
```

### `disconnect()`
Disconnects from the current RFID reader.

```swift
rfidManager.disconnect { success, error in
    if let error = error {
        print("Disconnection error: \(error.localizedDescription)")
        return
    }
    
    if success {
        print("Disconnected successfully")
    }
}
```

### `reset()`
Resets the connected RFID reader.

```swift
rfidManager.reset { success, error in
    if let error = error {
        print("Reset error: \(error.localizedDescription)")
        return
    }
    
    if success {
        print("Device reset successfully")
    }
}
```

## Error Handling

The plugin uses Swift's error handling mechanism. Each method provides an optional `error` parameter to help diagnose issues.

## Permissions

Ensure you have the following permissions in your `Info.plist`:
- Privacy - Bluetooth Always Usage Description
- Privacy - Bluetooth Peripheral Usage Description

## Example Complete Workflow

```swift
let rfidManager = ChanelRFIDPlugin()

// List devices
rfidManager.listDevices { devices, error in
    guard let firstDevice = devices.first else { return }
    
    // Connect to device
    rfidManager.connect(to: firstDevice) { success, error in
        guard success else { return }
        
        // Start scanning
        rfidManager.startScan { rfidTag, error in
            print("Scanned Tag: \(rfidTag)")
        }
        
        // Later, stop scanning
        rfidManager.stopScan { _, _ in }
        
        // Disconnect when done
        rfidManager.disconnect { _, _ in }
    }
}
```

## Compatibility

- Minimum iOS Version: 14.0
- Swift Version: 5.9
- Supports Bluetooth Low Energy (BLE)

## Notes

- Ensure Bluetooth is enabled on the device
- Some methods may require user permissions
- Performance and reliability depend on the specific Channel RFID reader model
