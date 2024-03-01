//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/28/24.
//

import Foundation


struct DataHandler {
    public enum DataEncodingStrategy {
            /// Defer to `Data` for choosing an encoding.
            case deferredToData

            /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
            case base64

            /// Encode the `Data` as a custom value encoded by the given closure.
            ///
            /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
            case custom((Data, Encoder) throws -> Void)
        }
    
//    func wrapData(_ data: Data, for additionalKey: CodingKey?) throws -> JSONValue {
//            switch self.options.dataEncodingStrategy {
//            case .deferredToData:
//                let encoder = self.getEncoder(for: additionalKey)
//                try data.encode(to: encoder)
//                return encoder.value ?? .null
//
//            case .base64:
//                let base64 = data.base64EncodedString()
//                return .string(base64)
//
//            case .custom(let closure):
//                let encoder = self.getEncoder(for: additionalKey)
//                try closure(data, encoder)
//                // The closure didn't encode anything. Return the default keyed container.
//                return encoder.value ?? .object([:])
//            }
//        }
}


