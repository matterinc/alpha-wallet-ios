import XCTest
@testable import AlphaWallet
import TrustKeystore
import RealmSwift
import BigInt

class OrderSigningTests: XCTestCase {

    func testSigningOrders() {
        let keystore = try! EtherKeystore()
        let contractAddress = "0xacDe9017473D7dC82ACFd0da601E4de291a7d6b0"
        let account = keystore.createAccount(password: "test")
        var testOrdersList = [Order]()
        //set up test orders
        var indices = [UInt16]()
        indices.append(14)

        let testOrder1 = Order(price: BigUInt("0")!,
                               indices: indices,
                               expiry: BigUInt("0")!,
                               contractAddress: contractAddress,
                               start: BigUInt("91239231313")!,
                               count: 3,
                               tokenIds: [BigUInt](),
                               spawnable: false
        )
        for _ in 0...2015 {
            testOrdersList.append(testOrder1)
        }
        let signOrders = OrderHandler()
        let signedOrders = try! signOrders.signOrders(orders: testOrdersList, account: account)
        XCTAssertGreaterThanOrEqual(2016, signedOrders.count)
        keystore.delete(wallet: Wallet(type: WalletType.real(account)))
    }
}

