import XCTest
import BCFoundation
import WolfBase

class PrivateKeyBaseTests: XCTestCase {
    func testPrivateKeyBase() {
        let seed = Seed(data: ‡"59f2293a5bce7d4de59e71b4207ac5d2")!
        let prvkeys = PrivateKeyBase(seed, salt: "salt")
        
        // print(prvkeys.signingPrivateKey.rawValue.hex)
        // print(prvkeys.signingPublicKey.rawValue.hex)
        // print(prvkeys.agreementPrivateKey.rawValue.hex)
        // print(prvkeys.agreementPublicKey.rawValue.hex)
        
        XCTAssertEqual(prvkeys.signingPrivateKey.data, ‡"79dfae4060d2c79c9588b0108307c3edc486840ca5e809badd9aa7296913b2a6")
        XCTAssertEqual(prvkeys.signingPrivateKey.schnorrPublicKey.data, ‡"72dd19bc0ebf5ba3dc2abc68b121e89f35169fb481ef3efed6beea30fc4b7759")
        XCTAssertEqual(prvkeys.agreementPrivateKey.data, ‡"5566b162781c0294a051209131e0c606c37f2c359515aa0160ad3a3255b9deb4")
        XCTAssertEqual(prvkeys.agreementPrivateKey.publicKey.data, ‡"040b0105518b038012319b5956059a7601bd8ada36b4e98386e801789627a40d")
    }
}
