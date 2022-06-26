//
//  AccountOutputType.swift
//  
//
//  Created by Wolf McNally on 12/7/21.
//

import Foundation
import WolfBase

public struct AccountOutputType: Hashable, Identifiable {
    public let name: String
    public let shortName: String
    public let descriptorSource: String
    public let accountDerivationPath: String
    public let addressDerivationPath: String?
    
    public var id: String {
        shortName
    }

    public func descriptorSource(accountKey: HDKeyProtocol) -> String {
        let keyExpression = accountKey.description(withParent: true)
        return descriptorSource(keyExpression: keyExpression)
    }

    public func descriptorSource(keyExpression: String) -> String {
        var keyComponents = [keyExpression]
        if let addressDerivationPath {
            keyComponents.append(addressDerivationPath)
        }
        return self.descriptorSource.replacingOccurrences(of: "KEY", with: keyComponents.joined(separator: "/"))
    }
    
    public func accountDerivationPath(network: Network, account: UInt32) -> DerivationPath {
        let coinType = UseInfo(network: network).coinType†
        return DerivationPath(string: self.accountDerivationPath
            .replacingOccurrences(of: "COIN_TYPE", with: coinType)
            .replacingOccurrences(of: "ACCOUNT", with: account†))!
    }

    public func accountDescriptor(masterKey: HDKeyProtocol, network: Network, account: UInt32) throws -> OutputDescriptor {
        let accountKey = try accountPublicKey(masterKey: masterKey, network: network, account: account)
        let source = descriptorSource(accountKey: accountKey)
        return try OutputDescriptor(source)
    }
    
    public func accountPublicKey(masterKey: HDKeyProtocol, network: Network, account: UInt32) throws -> HDKey {
        let path = accountDerivationPath(network: network, account: account)
        return try HDKey(parent: masterKey, derivedKeyType: .public, childDerivationPath: path)
    }
    
    public func matchesPath(_ path: DerivationPath) -> Bool {
        let myPath = DerivationPath(string: accountDerivationPath)!
        guard path.count == myPath.count else {
            return false
        }
        for (step, myStep) in zip(path.steps, myPath.steps) {
            guard let basicStep = step as? BasicDerivationStep else {
                return false
            }
            guard let myBasicStep = myStep as? BasicDerivationStep else {
                return false
            }
            guard basicStep.isHardened == myBasicStep.isHardened else {
                return false
            }
            switch myBasicStep.childIndexSpec {
            case .index(let myIndex):
                guard
                    case let .index(index) = basicStep.childIndexSpec,
                    index == myIndex
                else {
                    return false
                }
            case .coinTypePlaceholder:
                guard
                    case let .index(index) = basicStep.childIndexSpec,
                    index == 0 || index == 1
                else {
                    return false
                }
            case .accountPlaceholder:
                guard
                    case .index = basicStep.childIndexSpec
                else {
                    return false
                }
            default:
                break
            }
        }
        return true
    }
    
    public static func firstMatching(in types: [AccountOutputType], path: DerivationPath) -> AccountOutputType? {
        types.first {
            $0.matchesPath(path)
        }
    }
    
    public static func firstMatching(path: DerivationPath) -> AccountOutputType? {
        firstMatching(in: bundleCases, path: path)
    }
    
    public static let pkh = AccountOutputType(
        name: "Legacy Single Key",
        shortName: "legacy",
        descriptorSource: "pkh(KEY)",
        accountDerivationPath: "44'/COIN_TYPE'/ACCOUNT'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let shwpkh = AccountOutputType(
        name: "Nested Segwit Single Key",
        shortName: "nested",
        descriptorSource: "sh(wpkh(KEY))",
        accountDerivationPath: "49'/COIN_TYPE'/ACCOUNT'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let wpkh = AccountOutputType(
        name: "Native Segwit Single Key",
        shortName: "segwit",
        descriptorSource: "wpkh(KEY)",
        accountDerivationPath: "84'/COIN_TYPE'/ACCOUNT'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let shcosigner = AccountOutputType(
        name: "Legacy Multisig Cosigner",
        shortName: "legacymultisig",
        descriptorSource: "sh(cosigner(KEY))",
        accountDerivationPath: "45'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let shwshcosigner = AccountOutputType(
        name: "Nested Segwit Multisig Cosigner",
        shortName: "nestedmultisig",
        descriptorSource: "sh(wsh(cosigner(KEY)))",
        accountDerivationPath: "48'/COIN_TYPE'/ACCOUNT'/1'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let wshcosigner = AccountOutputType(
        name: "Native Segwit Multisig Cosigner",
        shortName: "segwitmultisig",
        descriptorSource: "wsh(cosigner(KEY))",
        accountDerivationPath: "48'/COIN_TYPE'/ACCOUNT'/2'",
        addressDerivationPath: "<0;1>/*"
    )

    public static let trsingle = AccountOutputType(
        name: "Taproot Single Key",
        shortName: "taproot",
        descriptorSource: "tr(KEY)",
        accountDerivationPath: "86'/COIN_TYPE'/ACCOUNT'",
        addressDerivationPath: "<0;1>/*"
    )
    
    public static let bundleCases = [
        pkh,
        shwpkh,
        wpkh,
        shcosigner,
        shwshcosigner,
        wshcosigner,
        trsingle,
    ]
}
