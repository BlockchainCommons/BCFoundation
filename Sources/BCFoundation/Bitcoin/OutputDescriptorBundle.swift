//
//  OutputDescriptorBundle.swift
//  
//
//  Created by Wolf McNally on 12/5/21.
//

import Foundation
@_exported import URKit

// https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-015-account.md

public struct OutputDescriptorBundle {
    public let masterKey: HDKeyProtocol
    public let network: Network
    public let account: UInt32
    public let descriptors: [OutputDescriptor]
    public let descriptorsByOutputType: [AccountOutputType: OutputDescriptor]
    
    public init?(masterKey: HDKeyProtocol, network: Network, account: UInt32, outputTypes: [AccountOutputType] = AccountOutputType.bundleCases) {
        guard
            masterKey.isMaster,
            !outputTypes.isEmpty,
            let descriptors: [OutputDescriptor] = try? outputTypes.map( {
                let a = try $0.accountDescriptor(masterKey: masterKey, network: network, account: account)
                return a;
            })
        else {
            return nil
        }
        var descriptorsByOutputType: [AccountOutputType: OutputDescriptor] = [:]
        zip(outputTypes, descriptors).forEach {
            descriptorsByOutputType[$0] = $1
        }
        self.masterKey = masterKey
        self.network = network
        self.account = account
        self.descriptors = descriptors
        self.descriptorsByOutputType = descriptorsByOutputType
    }
    
    public var untaggedCBOR: CBOR {
        // https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-015-account.md#cddl
        CBOR.orderedMap([
            1: .unsignedInt(UInt64(masterKey.keyFingerprint)),
            2: .array(descriptors.map{ $0.taggedCBOR })
        ])
    }
    
    public var taggedCBOR: CBOR {
        CBOR.tagged(URType.account.tag, untaggedCBOR)
    }
    
    public var ur: UR {
        try! UR(type: URType.account.type, cbor: untaggedCBOR)
    }
}
