import Foundation
import CoreBluetooth

/// Main class for interacting with Chanel RFID readers via BLE
public class ChanelRFIDPlugin: NSObject {
    // MARK: - Properties
    
    /// Singleton instance of CBCentralManager for BLE operations
    private var centralManager: CBCentralManager!
    
    /// Currently connected peripheral
    private var connectedPeripheral: CBPeripheral?
    
    /// Characteristic used for communication with the RFID reader
    private var writeCharacteristic: CBCharacteristic?
    
    /// Characteristic used for receiving notifications from the RFID reader
    private var notifyCharacteristic: CBCharacteristic?
    
    /// Queue for BLE operations
    private let queue = DispatchQueue(label: "com.chanel.rfidplugin.ble", qos: .userInitiated)
    
    /// Callback for device discovery
    private var discoveryCallback: (([BLEDevice], Error?) -> Void)?
    
    /// Callback for connection status
    private var connectionCallback: ((Bool, Error?) -> Void)?
    
    /// Callback for RFID scan results
    private var scanCallback: ((String?, Error?) -> Void)?
    
    /// Callback for scan stop status
    private var stopScanCallback: ((Bool, Error?) -> Void)?
    
    /// Callback for disconnection status
    private var disconnectionCallback: ((Bool, Error?) -> Void)?
    
    /// Callback for reset status
    private var resetCallback: ((Bool, Error?) -> Void)?
    
    /// Callback for parameter set operations
    private var setParameterCallback: ((Bool, Error?) -> Void)?
    
    /// Callback for parameter get operations
    private var getParameterCallback: ((String?, Error?) -> Void)?
    
    /// List of discovered devices
    private var discoveredDevices: [BLEDevice] = []
    
    /// Flag to indicate if we're waiting for Bluetooth to power on
    private var pendingListDevicesCompletion: (([BLEDevice], Error?) -> Void)?
    
    // MARK: - Service and Characteristic UUIDs
    
    /// Service UUID for the RFID reader
    private let serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    
    /// Characteristic UUID for writing commands to the RFID reader
    private let writeUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    
    /// Characteristic UUID for receiving notifications from the RFID reader
    private let notifyUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    // MARK: - Initialization
    
    /// Initialize the RFID plugin
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    // MARK: - Public Methods
    
    /// Discovers and lists all BLE devices with "BZNC RFID READER" in their name
    /// - Parameter completion: Callback with discovered devices or error
    public func listDevices(completion: @escaping ([BLEDevice], Error?) -> Void) {
        // If Bluetooth is not yet powered on, store the completion handler and wait
        if centralManager.state != .poweredOn {
            pendingListDevicesCompletion = completion
            return
        }
        
        // If we get here, Bluetooth is powered on and ready
        startScanning(completion: completion)
    }
    
    /// Start scanning for BLE devices
    /// - Parameter completion: Callback with discovered devices or error
    private func startScanning(completion: @escaping ([BLEDevice], Error?) -> Void) {
        discoveredDevices = []
        discoveryCallback = completion
        
        // Start scanning for devices
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Stop scanning after 5 seconds
        queue.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            self.centralManager.stopScan()
            self.discoveryCallback?(self.discoveredDevices, nil)
            self.discoveryCallback = nil
        }
    }
    
    /// Connects to a specific Chanel RFID device
    /// - Parameters:
    ///   - device: The BLE device to connect to
    ///   - completion: Callback with connection status or error
    public func connect(to device: BLEDevice, completion: @escaping (Bool, Error?) -> Void) {
        guard let peripheral = device.peripheral else {
            completion(false, RFIDError.invalidDevice)
            return
        }
        
        connectionCallback = completion
        centralManager.connect(peripheral, options: nil)
    }
    
    /// Begins listening for RFID scans on the connected device
    /// - Parameter completion: Callback with scanned RFID tag or error
    public func startScan(completion: @escaping (String?, Error?) -> Void) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            completion(nil, RFIDError.notConnected)
            return
        }
        
        scanCallback = completion
        
        // Send command to start scanning
        let command = "set|scan|1"
        guard let data = command.data(using: .utf8) else {
            completion(nil, RFIDError.invalidCommand)
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    /// Stops listening for RFID scans
    /// - Parameter completion: Callback with stop status or error
    public func stopScan(completion: @escaping (Bool, Error?) -> Void) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            completion(false, RFIDError.notConnected)
            return
        }
        
        stopScanCallback = completion
        
        // Send command to stop scanning
        let command = "set|scan|0"
        guard let data = command.data(using: .utf8) else {
            completion(false, RFIDError.invalidCommand)
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    /// Disconnects from the current RFID reader
    /// - Parameter completion: Callback with disconnection status or error
    public func disconnect(completion: @escaping (Bool, Error?) -> Void) {
        guard let peripheral = connectedPeripheral else {
            completion(false, RFIDError.notConnected)
            return
        }
        
        disconnectionCallback = completion
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    /// Resets the connected RFID reader
    /// - Parameter completion: Callback with reset status or error
    public func reset(completion: @escaping (Bool, Error?) -> Void) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            completion(false, RFIDError.notConnected)
            return
        }
        
        resetCallback = completion
        
        // Send command to reset the device
        let command = "reboot"
        guard let data = command.data(using: .utf8) else {
            completion(false, RFIDError.invalidCommand)
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    /// Sets a parameter on the connected RFID reader
    /// - Parameters:
    ///   - parameter: The parameter name ("power", "region", or "interval")
    ///   - value: The parameter value
    ///   - completion: Callback with success status or error
    public func setParameter(_ parameter: String, value: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            completion(false, RFIDError.notConnected)
            return
        }
        
        // Validate parameter and value
        guard isValidParameter(parameter) else {
            completion(false, RFIDError.invalidParameter)
            return
        }
        
        guard isValidParameterValue(parameter: parameter, value: value) else {
            completion(false, RFIDError.invalidParameterValue)
            return
        }
        
        setParameterCallback = completion
        
        // Send command to set parameter
        let command = "set|\(parameter)|\(value)"
        guard let data = command.data(using: .utf8) else {
            completion(false, RFIDError.invalidCommand)
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    /// Gets a parameter value from the connected RFID reader
    /// - Parameters:
    ///   - parameter: The parameter name ("power", "region", or "interval")
    ///   - completion: Callback with parameter value or error
    public func getParameter(_ parameter: String, completion: @escaping (String?, Error?) -> Void) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            completion(nil, RFIDError.notConnected)
            return
        }
        
        // Validate parameter
        guard isValidParameter(parameter) else {
            completion(nil, RFIDError.invalidParameter)
            return
        }
        
        getParameterCallback = completion
        
        // Send command to get parameter
        let command = "get|\(parameter)"
        guard let data = command.data(using: .utf8) else {
            completion(nil, RFIDError.invalidCommand)
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // MARK: - Private Parameter Validation Methods
    
    /// Validates if the parameter name is supported
    /// - Parameter parameter: The parameter name to validate
    /// - Returns: True if the parameter is valid, false otherwise
    private func isValidParameter(_ parameter: String) -> Bool {
        let validParameters = ["power", "region", "interval"]
        return validParameters.contains(parameter)
    }
    
    /// Validates if the parameter value is valid for the given parameter
    /// - Parameters:
    ///   - parameter: The parameter name
    ///   - value: The parameter value to validate
    /// - Returns: True if the value is valid for the parameter, false otherwise
    private func isValidParameterValue(parameter: String, value: String) -> Bool {
        switch parameter {
        case "power":
            // Power values: 1500 to 2600 by increments of 100
            guard let powerValue = Int(value) else { return false }
            return powerValue >= 1500 && powerValue <= 2600 && powerValue % 100 == 0
            
        case "region":
            // Region values: "CN1", "CN2", "US", "EU", "KO"
            let validRegions = ["CN1", "CN2", "US", "EU", "KO"]
            return validRegions.contains(value)
            
        case "interval":
            // Interval: any positive integer (duration in ms)
            guard let intervalValue = Int(value) else { return false }
            return intervalValue > 0
            
        default:
            return false
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension ChanelRFIDPlugin: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // If we were waiting for Bluetooth to power on, start scanning now
            if let completion = pendingListDevicesCompletion {
                startScanning(completion: completion)
                pendingListDevicesCompletion = nil
            }
        } else {
            // If Bluetooth is not powered on, notify any active callbacks
            discoveryCallback?([], RFIDError.notConnected)
            connectionCallback?(false, RFIDError.notConnected)
            scanCallback?(nil, RFIDError.notConnected)
            stopScanCallback?(false, RFIDError.notConnected)
            disconnectionCallback?(false, RFIDError.notConnected)
            resetCallback?(false, RFIDError.notConnected)
            setParameterCallback?(false, RFIDError.notConnected)
            getParameterCallback?(nil, RFIDError.notConnected)
            
            // Also notify any pending list devices completion
            pendingListDevicesCompletion?([], RFIDError.notConnected)
            pendingListDevicesCompletion = nil
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the device name contains "BZNC RFID READER"
        if let name = peripheral.name, name.contains("BZNC RFID READER") {
            let device = BLEDevice(peripheral: peripheral, name: name, rssi: RSSI.intValue)
            
            // Add to discovered devices if not already present
            if !discoveredDevices.contains(where: { $0.id == device.id }) {
                discoveredDevices.append(device)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionCallback?(false, error ?? RFIDError.connectionFailed)
        connectionCallback = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
        
        if let error = error {
            disconnectionCallback?(false, error)
        } else {
            disconnectionCallback?(true, nil)
        }
        
        disconnectionCallback = nil
    }
}

// MARK: - CBPeripheralDelegate

extension ChanelRFIDPlugin: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            connectionCallback?(false, error)
            connectionCallback = nil
            return
        }
        
        guard let services = peripheral.services else {
            connectionCallback?(false, RFIDError.serviceNotFound)
            connectionCallback = nil
            return
        }
        
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([writeUUID, notifyUUID], for: service)
                return
            }
        }
        
        connectionCallback?(false, RFIDError.serviceNotFound)
        connectionCallback = nil
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            connectionCallback?(false, error)
            connectionCallback = nil
            return
        }
        
        guard let characteristics = service.characteristics else {
            connectionCallback?(false, RFIDError.characteristicNotFound)
            connectionCallback = nil
            return
        }
        
        var foundWrite = false
        var foundNotify = false
        
        for characteristic in characteristics {
            if characteristic.uuid == writeUUID {
                writeCharacteristic = characteristic
                foundWrite = true
            } else if characteristic.uuid == notifyUUID {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                foundNotify = true
            }
            
            if foundWrite && foundNotify {
                connectionCallback?(true, nil)
                connectionCallback = nil
                return
            }
        }
        
        connectionCallback?(false, RFIDError.characteristicNotFound)
        connectionCallback = nil
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            scanCallback?(nil, error)
            return
        }
        print("Received data")
        guard let data = characteristic.value, let response = String(data: data, encoding: .utf8) else {
            return
        }
        // log data
        print("Received data: \(response)")
        
        // Process the response based on the expected format
        // For RFID scans, we expect a format like "tag|12345678"
        if response.hasPrefix("tag|") {
            let tag = String(response.dropFirst(4))
            print("send tag: \(tag)")
            scanCallback?(tag, nil)
        } else if response.contains("SCAN:0") {
            stopScanCallback?(true, nil)
            stopScanCallback = nil
        } else if response.contains("REBOOT:OK") {
            resetCallback?(true, nil)
            resetCallback = nil
        } else if response.hasPrefix("SET:OK") {
            // Parameter set operation successful
            setParameterCallback?(true, nil)
            setParameterCallback = nil
        } else if response.hasPrefix("SET:ERROR") {
            // Parameter set operation failed
            setParameterCallback?(false, RFIDError.parameterOperationFailed)
            setParameterCallback = nil
        } else if response.contains("|") && getParameterCallback != nil {
            // Parameter get response format: "parameter|value"
            let components = response.components(separatedBy: "|")
            if components.count >= 2 {
                let value = components[1]
                getParameterCallback?(value, nil)
                getParameterCallback = nil
            } else {
                getParameterCallback?(nil, RFIDError.parameterOperationFailed)
                getParameterCallback = nil
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            if characteristic.uuid == writeUUID {
                if scanCallback != nil {
                    scanCallback?(nil, error)
                } else if stopScanCallback != nil {
                    stopScanCallback?(false, error)
                    stopScanCallback = nil
                } else if resetCallback != nil {
                    resetCallback?(false, error)
                    resetCallback = nil
                } else if setParameterCallback != nil {
                    setParameterCallback?(false, error)
                    setParameterCallback = nil
                } else if getParameterCallback != nil {
                    getParameterCallback?(nil, error)
                    getParameterCallback = nil
                }
            }
        }
    }
}
