
# Tuvali - A library to send vc/vp using BLE.
This is the module for the OpenID for Verifiable Presentations over BLE implementation to support sending vc/vp using Bluetooth Low Energy local channel.

## Usage as a Swift library (for native ios)    
- Add the github link as a spm package dependency in swift project.
- Select the appropriate branch/version.

## API documentation
Firstly, for establishing the secured connection over BLE the Verifier's URI needs to be exchanged between two devices. The exchange of URI can be accomplished, but is not limited to, by using a QR code.

For example use QR code generator to visually display URI and QR code scanner to read. A mobile app that displays a QR code can act as an Verifier by including its URI as data in the QR code and another device can act as Wallet which scans the QR code, it can extract the URI and initiate a BLE connection with the advertising device.

## URI Exchange and Establishing Connection

### Verifier

The Verifier device generates a URI using the `startAdvertisement()` method and displays it as a QR code. Once the advertisement starts, the Verifier continuously advertises with a payload derived from the URI.

#### URI contains:
```
OPENID4VP://connect?name=STADONENTRY&key=8520f0098930a754748b7ddcb43ef75a0dbf3a0d26381af4eba4a98eaa9b4e6a
```
URI structure can be found in the [spec](https://bitbucket.org/openid/connect/src/master/openid-4-verifiable-presentations-over-ble/openid-4-verifiable-presentations-over-ble-1_0.md).
An iOS device can act as either the Verifier or the Wallet.

### Wallet

### Start Connection
The Wallet device scans the QR code, extracts the URI, and starts scanning using the `startConnection` method.

```swift
class Wallet:WalletProtocol {
  
 
  func startConnection(_ uri: String) {
    // Implementation for starting the connection
  }
  ```
 ### End Connection
 The device on which app is running can destroy the connection by calling `disconnect` method:

 ```swift
  func disconnect() {
    // Implementation for disconnecting
  }
  ```

### Share Data
Once the connection is established, Wallet can send the data by:
```swift
  func sendData(_ payload: String) {
    // Implementation for sending data
  }
}
```
Wallet will start sending data in a secured way to the Verifier.
Note: At this moment, we currently support data transfer from Wallet to Verifier only.
### Usage:

#### Start Connection

```swift
import ios_tuvali_library

var wallet=Wallet()
wallet.startConnection(uri, resolver: { result in
  print("Connection started: \(result)")
}, rejecter: { code, message, error in
  print("Error starting connection: \(message)")
})
```

#### Disconnect

```swift
import ios_tuvali_library

var wallet=Wallet()
wallet.disconnect(resolver: { result in
  print("Disconnected: \(result)")
}, rejecter: { code, message, error in
  print("Error disconnecting: \(message)")
})
```

#### Send Data

```swift
import ios_tuvali_library

let payload = "your-data-here"
var wallet=Wallet()
wallet.sendData(payload, resolver: { result in
  print("Data sent: \(result)")
}, rejecter: { code, message, error in
  print("Error sending data: \(message)")
})
```

### Verifier Usage:

#### Start Advertisement

`startAdvertisement` starts advertising under the given name and returns the URI to show as a QR code.

```swift
import ios_tuvali_library

let verifier = Verifier()
verifier.subscribe { event in
  if let received = event as? DataReceivedEvent {
    print("Received: \(received.data)")
  }
}
let uri = verifier.startAdvertisement("STADONENTRY")
```

#### Send Verification Status

After checking the received data, tell the Wallet whether it was accepted.

```swift
verifier.sendVerificationStatus(.ACCEPTED) // or .REJECTED
```

#### Disconnect

```swift
verifier.disconnect()
verifier.unsubscribe()
```

## Events
Tuvali sends multiple events to propagate connection status, received data etc. These events can be subscribed to by calling:
### Wallet Events

```swift
WalletModule.handleDataEvents { 
// implementation
}
```

### Verifier Events

1. DataReceivedEvent
   * when the Wallet's data has been received, decrypted and decompressed, with `data`, `crcFailureCount` and `totalChunkCount`

### Common Events
Events which are emitted by both Wallet and Verifier

1. ConnectedEvent
   * on BLE connection getting established between Wallet and Verifier
2. SecureChannelEstablishedEvent
   * on completion of key exchange between Wallet and Verifier
3. ErrorEvent
   * on any error in Wallet or Verifier
4. DisconnectedEvent
   * on BLE disconnection between Wallet and Verifier

## Note
Currently, data transfer is supported from Wallet to Verifier only.

## ISO 18013-5 mdoc session testing

The ISO path exposes `MdocPresenter` for QR engagement, BLE central-client transport, encrypted
requests/responses and reader authentication. A wallet supplies consent and its signed DeviceResponse.
See the [simple iOS demo](example/iso-mdoc-demo/README.md) for session testing.
