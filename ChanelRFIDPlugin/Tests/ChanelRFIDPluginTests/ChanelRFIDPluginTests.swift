import XCTest
@testable import ChanelRFIDPlugin

final class ChanelRFIDPluginTests: XCTestCase {
    func testInitialization() {
        // This is a basic test to ensure the plugin can be initialized
        let plugin = ChanelRFIDPlugin()
        XCTAssertNotNil(plugin)
    }
    
    func testBLEDeviceCreation() {
        // Since we can't easily create a CBPeripheral in tests,
        // this test is more of a placeholder for future tests
        // that would mock the CoreBluetooth dependencies
    }
    
    func testRFIDErrorDescriptions() {
        // Test that all error cases have descriptions
        XCTAssertNotNil(RFIDError.bluetoothNotAvailable.errorDescription)
        XCTAssertNotNil(RFIDError.invalidDevice.errorDescription)
        XCTAssertNotNil(RFIDError.notConnected.errorDescription)
        XCTAssertNotNil(RFIDError.connectionFailed.errorDescription)
        XCTAssertNotNil(RFIDError.serviceNotFound.errorDescription)
        XCTAssertNotNil(RFIDError.characteristicNotFound.errorDescription)
        XCTAssertNotNil(RFIDError.invalidCommand.errorDescription)
        XCTAssertNotNil(RFIDError.scanFailed.errorDescription)
        XCTAssertNotNil(RFIDError.generalError("Test").errorDescription)
    }
}
