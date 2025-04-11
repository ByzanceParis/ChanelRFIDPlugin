Pod::Spec.new do |s|
  s.name             = 'ChanelRFIDPlugin'
  s.version          = '1.0.0'
  s.summary          = 'iOS plugin for interacting with Chanel RFID readers via BLE'
  
  s.description      = <<-DESC
  The ChanelRFIDPlugin is an iOS plugin designed to interact with Channel RFID readers via Bluetooth Low Energy (BLE).
  This plugin provides a simple interface for discovering, connecting, and communicating with RFID devices.
                       DESC
  
  s.homepage         = 'https://github.com/ByzanceParis/ChanelRFIDPlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chanel' => 'developer@chanel.com' }
  s.source           = { :git => 'https://github.com/ByzanceParis/ChanelRFIDPlugin.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.9'
  
  s.source_files = 'Sources/ChanelRFIDPlugin/**/*'
  
  s.frameworks = 'Foundation', 'CoreBluetooth'
end
