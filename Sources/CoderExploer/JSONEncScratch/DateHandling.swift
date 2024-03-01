//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/28/24.
//

import Foundation


//Not Currently Used. 

struct DateHandler {
    var strategy:DateEncodingStrategy
    
    
    public enum DateEncodingStrategy {
            /// Defer to `Date` for choosing an encoding. This is the default strategy.
            case deferredToDate

            /// Encode the `Date` as a UNIX timestamp (as a JSON number).
            case secondsSince1970

            /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
            case millisecondsSince1970

            /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
            @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
            case iso8601

            /// Encode the `Date` as a string formatted by the given formatter.
            case formatted(DateFormatter)

            /// Encode the `Date` as a custom value encoded by the given closure.
            ///
            /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
            case custom((Date, Encoder) throws -> Void)
        }
    
    internal var _iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()

    
//    func wrapDate(_ date: Date, additionalKey: CodingKey?) throws -> LCEncodedValue {
//        switch self.strategy {
//        case .deferredToDate:
////            let encoder = self.getEncoder(for: additionalKey)
////            try date.encode(to: encoder)
////            return encoder.value ?? .null
//            
//        case .secondsSince1970:
//            return .number(date.timeIntervalSince1970.description)
//            
//        case .millisecondsSince1970:
//            return .number((date.timeIntervalSince1970 * 1000).description)
//            
//        case .iso8601:
//            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
//                return .string(_iso8601Formatter.string(from: date))
//            } else {
//                fatalError("ISO8601DateFormatter is unavailable on this platform.")
//            }
//            
//        case .formatted(let formatter):
//            return .string(formatter.string(from: date))
//            
//        case .custom(let closure):
////            let encoder = self.getEncoder(for: additionalKey)
////            try closure(date, encoder)
////            // The closure didn't encode anything. Return the default keyed container.
////            return encoder.value ?? .object([:])
//        }
//    }
}
