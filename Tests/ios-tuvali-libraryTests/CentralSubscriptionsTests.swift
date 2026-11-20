import XCTest
import CoreBluetooth
@testable import ios_tuvali_library

final class CentralSubscriptionsTests: XCTestCase {
    private let wallet = UUID()
    private let request = CBUUID(string: "00000006-5026-444A-9E0E-D6F2450F3A77")
    private let response = CBUUID(string: "00000007-5026-444A-9E0E-D6F2450F3A77")
    private let status = CBUUID(string: "00000008-5026-444A-9E0E-D6F2450F3A77")

    func testOnlyAWalletsFirstSubscriptionCountsAsItConnecting() {
        var subscriptions = CentralSubscriptions()

        let first = subscriptions.subscribe(central: wallet, characteristic: request)
        let second = subscriptions.subscribe(central: wallet, characteristic: response)
        let third = subscriptions.subscribe(central: wallet, characteristic: status)

        XCTAssertEqual([first, second, third], [true, false, false])
    }

    func testDroppingOneOfSeveralSubscriptionsDoesNotCountAsTheWalletDisconnecting() {
        var subscriptions = CentralSubscriptions()
        _ = subscriptions.subscribe(central: wallet, characteristic: request)
        _ = subscriptions.subscribe(central: wallet, characteristic: response)

        let disconnected = subscriptions.unsubscribe(central: wallet, characteristic: request)

        XCTAssertFalse(disconnected)
    }

    func testDroppingTheLastSubscriptionCountsAsTheWalletDisconnecting() {
        var subscriptions = CentralSubscriptions()
        _ = subscriptions.subscribe(central: wallet, characteristic: request)
        _ = subscriptions.subscribe(central: wallet, characteristic: response)
        _ = subscriptions.unsubscribe(central: wallet, characteristic: request)

        let disconnected = subscriptions.unsubscribe(central: wallet, characteristic: response)

        XCTAssertTrue(disconnected)
    }

    func testAnUnsubscribeFromAnUnknownWalletIsNotADisconnection() {
        var subscriptions = CentralSubscriptions()

        let disconnected = subscriptions.unsubscribe(central: wallet, characteristic: request)

        XCTAssertFalse(disconnected)
    }

    func testAfterRemoveAllTheNextSubscriptionCountsAsANewConnection() {
        var subscriptions = CentralSubscriptions()
        _ = subscriptions.subscribe(central: wallet, characteristic: request)
        subscriptions.removeAll()

        let connected = subscriptions.subscribe(central: wallet, characteristic: response)

        XCTAssertTrue(connected)
    }
}
