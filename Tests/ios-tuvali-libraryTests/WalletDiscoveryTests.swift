import XCTest
import CoreBluetooth
@testable import ios_tuvali_library

final class WalletDiscoveryTests: XCTestCase {
    private let verifierKeyHex = String(repeating: "ab", count: 32)

    private func uri(key: String) -> OpenId4vpURI {
        OpenId4vpURI(uri: "OPENID4VP://connect?name=AbCd1234&key=\(key)")
    }

    func testAQRWithA32ByteHexKeyIsValid() {
        XCTAssertTrue(uri(key: verifierKeyHex).isValid())
    }

    func testAQRWithAnOddLengthKeyIsRejectedBeforeTheKeyIsDecoded() {
        // 63 hex digits: the last byte has only one digit
        let oddLength = String(verifierKeyHex.dropLast())

        XCTAssertFalse(uri(key: oddLength).isValid())
    }

    func testAQRWithANonHexKeyIsRejectedBeforeTheKeyIsDecoded() {
        let notHex = "zz" + verifierKeyHex.dropFirst(2)

        XCTAssertFalse(uri(key: notHex).isValid())
    }

    func testAQRWithAKeyShorterThan32BytesIsRejected() {
        // 5 bytes would have been enough for the advertisement prefix, but not for the key exchange
        let fiveBytes = String(repeating: "ab", count: 5)

        XCTAssertFalse(uri(key: fiveBytes).isValid())
    }

    private func communicator(expectingName name: String) -> WalletBleCommunicator {
        let communicator = WalletBleCommunicator()
        communicator.setVerifierPublicKey(publicKeyData: Data(repeating: 0xAB, count: 32))
        communicator.setAdvName(name)
        return communicator
    }

    func testTheWalletConnectsToAnIOSVerifierAdvertisingTheQRName() {
        let communicator = communicator(expectingName: "AbCd1234")

        let shouldConnect = communicator.shouldConnectToDiscoveredPeripheral(
            advertisementData: [CBAdvertisementDataLocalNameKey: "AbCd1234"]
        )

        XCTAssertTrue(shouldConnect)
    }

    func testTheWalletIgnoresADeviceAdvertisingAnotherName() {
        let communicator = communicator(expectingName: "AbCd1234")

        let shouldConnect = communicator.shouldConnectToDiscoveredPeripheral(
            advertisementData: [CBAdvertisementDataLocalNameKey: "Other123"]
        )

        XCTAssertFalse(shouldConnect)
    }

    func testTheWalletIgnoresADeviceWithoutALocalNameSoItKeepsScanningForTheQRVerifier() {
        let communicator = communicator(expectingName: "AbCd1234")

        let shouldConnect = communicator.shouldConnectToDiscoveredPeripheral(advertisementData: [:])

        XCTAssertFalse(shouldConnect)
    }
}
