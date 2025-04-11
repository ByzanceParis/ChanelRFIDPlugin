import Foundation
import CoreBluetooth

/// Represents a Bluetooth Low Energy device
public class BLEDevice: Identifiable {
    /// Unique identifier for the device
    public let id: UUID
    
    /// The name of the device
    public let name: String
    
    /// The signal strength of the device (RSSI)
    public let rssi: Int
    
    /// The underlying CBPeripheral object
    internal let peripheral: CBPeripheral?
    
    /// Initialize a new BLE device
    /// - Parameters:
    ///   - peripheral: The CoreBluetooth peripheral
    ///   - name: The name of the device
    ///   - rssi: The signal strength
    init(peripheral: CBPeripheral, name: String, rssi: Int) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.name = name
        self.rssi = rssi
    }
}

// MARK: - Equatable

extension BLEDevice: Equatable {
    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - CustomStringConvertible

extension BLEDevice: CustomStringConvertible {
    public var description: String {
        return "BLEDevice(name: \(name), rssi: \(rssi))"
    }
}
