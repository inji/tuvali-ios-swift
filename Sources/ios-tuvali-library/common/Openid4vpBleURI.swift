import Foundation

class OpenId4vpURI {
    var URI_IDENTIFIER = "OPENID4VP"
    let urlComponents: URLComponents?
    
    init(uri: String) {
        self.urlComponents = URLComponents(string: uri)
    }
    
    func getName() -> String? {
        return self.urlComponents?.queryItems?.first(where: { $0.name == "name" })?.value
    }
    
    func getHexPK() -> String? {
        return self.urlComponents?.queryItems?.first(where: { $0.name == "key" })?.value
    }
    
    func isValid() -> Bool {
        return self.urlComponents?.scheme == URI_IDENTIFIER && getName() != nil && isX25519HexKey(getHexPK())
    }

    // the key is decoded without checks later, and a malformed one would crash the app
    private func isX25519HexKey(_ key: String?) -> Bool {
        guard let key, key.count == 64 else { return false }
        return key.allSatisfy(\.isHexDigit)
    }
}
