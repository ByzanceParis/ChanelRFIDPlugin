# ChanelRFIDPlugin

An iOS plugin designed to interact with Chanel RFID readers via Bluetooth Low Energy (BLE).

## Features

- Discover and list Chanel RFID readers
- Connect to specific RFID devices
- Start and stop RFID scanning
- Receive RFID tag data
- Reset connected devices
- Comprehensive error handling

## Requirements

- iOS 14.0+
- Swift 5.9+
- Xcode 13.0+

## Installation

### CocoaPods

Add the following to your Podfile:

```ruby
pod 'ChanelRFIDPlugin'
```

Then run:

```bash
pod install
```

### Swift Package Manager

Add the package in Xcode:

1. Go to File > Swift Packages > Add Package Dependency
2. Enter the repository URL for the ChanelRFIDPlugin
3. Select the version you want to use

## Usage

### Import the Plugin

```swift
import ChanelRFIDPlugin
```

### Initialization

```swift
let rfidManager = ChanelRFIDPlugin()
```

### Discover Devices

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

### Connect to a Device

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

### Start Scanning for RFID Tags

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

### Stop Scanning

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

### Disconnect from Device

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

### Reset Device

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

## Permissions

Ensure you have the following permissions in your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to RFID readers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to connect to RFID readers</string>
```

## License

ChanelRFIDPlugin is available under the MIT license. See the LICENSE file for more info.
