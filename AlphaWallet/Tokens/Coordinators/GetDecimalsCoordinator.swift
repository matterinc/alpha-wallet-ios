// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import TrustKeystore
import web3swift

class GetDecimalsCoordinator {
    private let config: Config

    init(config: Config) {
        self.config = config
    }

    func getDecimals(
        for contract: Address,
        completion: @escaping (Result<UInt8, AnyError>) -> Void
    ) {
        guard let contractAddress = EthereumAddress(contract.eip55String) else {
            completion(.failure(AnyError(Web3Error(description: "Error converting contract address: \(contract.eip55String)"))))
            return
        }

        guard let webProvider = Web3HttpProvider(config.rpcURL, network: config.server.web3Network) else {
            completion(.failure(AnyError(Web3Error(description: "Error creating web provider for: \(config.rpcURL) + \(config.server.web3Network)"))))
            return
        }

        let web3 = web3swift.web3(provider: webProvider)
        let functionName = "decimals"
        guard let contractInstance = web3swift.web3.web3contract(web3: web3, abiString: web3swift.Web3.Utils.erc20ABI, at: contractAddress, options: web3.options) else {
            completion(.failure(AnyError(Web3Error(description: "Error creating web3swift contract instance to call \(functionName)()"))))
            return
        }

        guard let promise = contractInstance.method(functionName, options: nil) else {
            completion(.failure(AnyError(Web3Error(description: "Error calling \(functionName)() on \(contract.eip55String)"))))
            return
        }
        promise.callPromise(options: nil).done { dictionary in
            if let decimalsWithUnknownType = dictionary["0"] {
                let string = String(describing: decimalsWithUnknownType)
                if let decimals = UInt8(string) {
                    completion(.success(decimals))
                } else {
                    completion(.failure(AnyError(Web3Error(description: "Error extracting result from \(contract.eip55String).\(functionName)()"))))
                }
            } else {
                completion(.failure(AnyError(Web3Error(description: "Error extracting result from \(contract.eip55String).\(functionName)()"))))
            }
        }.catch { error in
            completion(.failure(AnyError(Web3Error(description: "Error extracting result from \(contract.eip55String).\(functionName)(): \(error)"))))
        }
    }
}
