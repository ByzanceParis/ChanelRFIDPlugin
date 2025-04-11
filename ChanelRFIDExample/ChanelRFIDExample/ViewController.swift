import UIKit
import ChanelRFIDPlugin

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: Disconnected"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanResultLabel: UILabel = {
        let label = UILabel()
        label.text = "Not scanned yet..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deviceTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Scan", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5 // Make disabled buttons appear faded
        return button
    }()
    
    private let disconnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Disconnect", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5 // Make disabled buttons appear faded
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Device", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5 // Make disabled buttons appear faded
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh Devices", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private let rfidManager = ChanelRFIDPlugin()
    private var discoveredDevices: [BLEDevice] = []
    private var isScanning = false
    private var connectedDevice: BLEDevice?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupActions()
        
        // Start discovering devices when the app launches
        refreshDeviceList()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Chanel RFID Scanner"
        
        // Add subviews
        view.addSubview(statusLabel)
        view.addSubview(deviceTableView)
        view.addSubview(scanButton)
        view.addSubview(disconnectButton)
        view.addSubview(resetButton)
        view.addSubview(refreshButton)
        view.addSubview(scanResultLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            deviceTableView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            deviceTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deviceTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deviceTableView.heightAnchor.constraint(equalToConstant: 200),
            
            refreshButton.topAnchor.constraint(equalTo: deviceTableView.bottomAnchor, constant: 20),
            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            
            scanButton.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 20),
            scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scanButton.heightAnchor.constraint(equalToConstant: 44),
            
            disconnectButton.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20),
            disconnectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            disconnectButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            disconnectButton.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            scanResultLabel.topAnchor.constraint(equalTo: disconnectButton.bottomAnchor, constant: 30),
            scanResultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scanResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scanResultLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceCell")
    }
    
    private func setupActions() {
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // Helper method to update button state
    private func updateButtonState(_ button: UIButton, enabled: Bool) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    
    @objc private func scanButtonTapped() {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
    }
    
    @objc private func disconnectButtonTapped() {
        disconnect()
    }
    
    @objc private func resetButtonTapped() {
        resetDevice()
    }
    
    @objc private func refreshButtonTapped() {
        refreshDeviceList()
    }
    
    // MARK: - RFID Plugin Methods
    
    private func refreshDeviceList() {
        statusLabel.text = "Status: Searching for devices..."
        
        rfidManager.listDevices { [weak self] devices, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.statusLabel.text = "Status: Error - \(error.localizedDescription)"
                    return
                }
                
                self.discoveredDevices = devices
                self.deviceTableView.reloadData()
                
                if devices.isEmpty {
                    self.statusLabel.text = "Status: No devices found"
                } else {
                    self.statusLabel.text = "Status: Found \(devices.count) device(s)"
                }
            }
        }
    }
    
    private func connectToDevice(_ device: BLEDevice) {
        statusLabel.text = "Status: Connecting to \(device.name)..."
        
        rfidManager.connect(to: device) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.statusLabel.text = "Status: Connection failed - \(error.localizedDescription)"
                    return
                }
                
                if success {
                    self.connectedDevice = device
                    self.statusLabel.text = "Status: Connected to \(device.name)"
                    self.updateButtonState(self.scanButton, enabled: true)
                    self.updateButtonState(self.disconnectButton, enabled: true)
                    self.updateButtonState(self.resetButton, enabled: true)
                } else {
                    self.statusLabel.text = "Status: Connection failed"
                }
            }
        }
    }
    
    private func startScan() {
        scanResultLabel.text = "No RFID tag scanned"
        rfidManager.startScan { [weak self] rfidTag, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.scanResultLabel.text = "Scan error: \(error.localizedDescription)"
                    return
                }
                
                if let tag = rfidTag {
                    self.scanResultLabel.text = "Scanned RFID Tag: \(tag)"
                }
            }
        }
        
        isScanning = true
        scanButton.setTitle("Stop Scan", for: .normal)
        scanButton.backgroundColor = .systemRed
        updateButtonState(scanButton, enabled: true)
    }
    
    private func stopScan() {
        
        scanResultLabel.text = "Not scanning..."
        
        rfidManager.stopScan { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.scanResultLabel.text = "Stop scan error: \(error.localizedDescription)"
                    return
                }
                
                if success {
                    self.scanResultLabel.text = "Scanning stopped"
                }
            }
        }
        
        isScanning = false
        scanButton.setTitle("Start Scan", for: .normal)
        scanButton.backgroundColor = .systemBlue
        scanResultLabel.text = ""
        updateButtonState(scanButton, enabled: true)
        
    }
    
    private func disconnect() {
        if isScanning {
            stopScan()
        }
        
        rfidManager.disconnect { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.statusLabel.text = "Status: Disconnection error - \(error.localizedDescription)"
                    return
                }
                
                if success {
                    self.statusLabel.text = "Status: Disconnected"
                    self.updateButtonState(self.scanButton, enabled: false)
                    self.updateButtonState(self.disconnectButton, enabled: false)
                    self.updateButtonState(self.resetButton, enabled: false)
                    self.connectedDevice = nil
                }
            }
        }
    }
    
    private func resetDevice() {
        rfidManager.reset { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.statusLabel.text = "Status: Reset error - \(error.localizedDescription)"
                    return
                }
                
                if success {
                    self.statusLabel.text = "Status: Device reset successfully"
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        let device = discoveredDevices[indexPath.row]
        
        cell.textLabel?.text = "\(device.name) (RSSI: \(device.rssi) dBm)"
        
        if let connectedDevice = connectedDevice, connectedDevice.id == device.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = discoveredDevices[indexPath.row]
        connectToDevice(device)
    }
}
