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
Discovers and lists all BLE devices with "BZNC RFID READER" in their name.

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

This function need to send 
    set|SCAN|1
to the device to start scanning



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
This function need to send 
    set|SCAN|0
to the device to stop scanning

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
This function need to send 
    reboot
to the device to reboot



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

### `setParameter(_ parameter: String, value: String)`
Sets a parameter on the connected RFID reader.
This function sends `set|{parameter}|{value}` to the device.

**Supported Parameters:**
- `power`: Values from 1500 to 2600 by increments of 100
- `region`: Values "CN1", "CN2", "US", "EU", "KO"
- `interval`: Duration in milliseconds between scans (any positive integer)

```swift
// Set power to 2000
rfidManager.setParameter("power", value: "2000") { success, error in
    if let error = error {
        print("Set parameter error: \(error.localizedDescription)")
        return
    }
    
    if success {
        print("Parameter set successfully")
    }
}

// Set region to EU
rfidManager.setParameter("region", value: "EU") { success, error in
    // Handle response
}

// Set scan interval to 500ms
rfidManager.setParameter("interval", value: "500") { success, error in
    // Handle response
}
```

### `getParameter(_ parameter: String)`
Gets a parameter value from the connected RFID reader.
This function sends `get|{parameter}` to the device.

**Supported Parameters:**
- `power`: Returns current power setting
- `region`: Returns current region setting
- `interval`: Returns current scan interval in milliseconds

```swift
// Get current power setting
rfidManager.getParameter("power") { value, error in
    if let error = error {
        print("Get parameter error: \(error.localizedDescription)")
        return
    }
    
    if let powerValue = value {
        print("Current power: \(powerValue)")
    }
}

// Get current region
rfidManager.getParameter("region") { value, error in
    if let regionValue = value {
        print("Current region: \(regionValue)")
    }
}

// Get current scan interval
rfidManager.getParameter("interval") { value, error in
    if let intervalValue = value {
        print("Current interval: \(intervalValue)ms")
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
        
        // Configure device parameters
        rfidManager.setParameter("power", value: "2000") { success, error in
            guard success else { return }
            
            rfidManager.setParameter("region", value: "EU") { success, error in
                guard success else { return }
                
                rfidManager.setParameter("interval", value: "500") { success, error in
                    guard success else { return }
                    
                    // Get current parameters to verify
                    rfidManager.getParameter("power") { value, error in
                        print("Current power: \(value ?? "unknown")")
                    }
                    
                    // Start scanning
                    rfidManager.startScan { rfidTag, error in
                        if let tag = rfidTag {
                            print("Scanned Tag: \(tag)")
                        }
                    }
                    
                    // Later, stop scanning
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        rfidManager.stopScan { _, _ in
                            // Disconnect when done
                            rfidManager.disconnect { _, _ in
                                print("Workflow completed")
                            }
                        }
                    }
                }
            }
        }
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
