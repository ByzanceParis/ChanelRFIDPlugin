import Foundation

/// Errors that can occur when using the RFID plugin
public enum RFIDError: Error {
    /// Bluetooth is not available or not powered on
    case bluetoothNotAvailable
    
    /// The device is invalid or not found
    case invalidDevice
    
    /// Not connected to an RFID reader
    case notConnected
    
    /// Failed to connect to the RFID reader
    case connectionFailed
    
    /// The required service was not found on the device
    case serviceNotFound
    
    /// The required characteristic was not found on the device
    case characteristicNotFound
    
    /// The command is invalid or could not be sent
    case invalidCommand
    
    /// A scan operation failed
    case scanFailed
    
    /// A general error occurred
    case generalError(String)
}

// MARK: - LocalizedError

extension RFIDError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .bluetoothNotAvailable:
            return "Bluetooth is not available or not powered on"
        case .invalidDevice:
            return "The device is invalid or not found"
        case .notConnected:
            return "Not connected to an RFID reader"
        case .connectionFailed:
            return "Failed to connect to the RFID reader"
        case .serviceNotFound:
            return "The required service was not found on the device"
        case .characteristicNotFound:
            return "The required characteristic was not found on the device"
        case .invalidCommand:
            return "The command is invalid or could not be sent"
        case .scanFailed:
            return "A scan operation failed"
        case .generalError(let message):
            return message
        }
    }
}
