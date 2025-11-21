//
//  INDIProtocolResult.swift
//  swift-indiclient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/11/18.
//

import Foundation

typealias INDIProtocolResult = INDIProtocolResultType<Bool, INDISocketError>

public enum INDIProtocolResultType<Value, Error>: Sendable where Value: Sendable, Error: Sendable {
    case success(Value)
    case failure(Error)
}

extension INDIProtocolResultType where Value == Bool, Error == Error {
    init(_ response: INDIProtocolResponse) {
        if let error = response.error {
            self = .failure(error as! Error)
        } else {
            self = .success(response.result)
        }
    }
}
