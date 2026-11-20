import Foundation
import CoreBluetooth

// a wallet subscribes to several characteristics, but connects and disconnects once
struct CentralSubscriptions {
    private var characteristicsByCentral: [UUID: Set<CBUUID>] = [:]

    /// True when this is the central's first subscription.
    mutating func subscribe(central: UUID, characteristic: CBUUID) -> Bool {
        let isFirst = characteristicsByCentral[central]?.isEmpty ?? true
        characteristicsByCentral[central, default: []].insert(characteristic)
        return isFirst
    }

    /// True when the central has no subscriptions left.
    mutating func unsubscribe(central: UUID, characteristic: CBUUID) -> Bool {
        guard var characteristics = characteristicsByCentral[central] else { return false }
        characteristics.remove(characteristic)
        guard characteristics.isEmpty else {
            characteristicsByCentral[central] = characteristics
            return false
        }
        characteristicsByCentral[central] = nil
        return true
    }

    mutating func removeAll() {
        characteristicsByCentral.removeAll()
    }
}
