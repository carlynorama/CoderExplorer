//
//  SimpleCoder+SingleValueEncoder.swift
//  
//
//  Created by Carlyn Maw on 3/4/24.
//

import Foundation

/// A single value container used by `URIValueToNodeEncoder`.
struct SimpleCoderSVEC {

    /// The associated encoder.
    let encoder: _SimpleEncoder
}

extension SimpleCoderSVEC {

    private func _setValue(_ converted:String) throws { try encoder.encode(converted, forKey: SVECCodingKey(converted)) }

    private func _setBinaryFloatingPoint(_ value: some BinaryFloatingPoint) throws {
        try _setValue(encoder.convert(value))
    }

    private func _setFixedWidthInteger(_ value: some FixedWidthInteger) throws {
        try _setValue(encoder.convert(value))
    }
    
    private func _setDate(_ value:Date) throws {
        try _setValue(encoder.convert(value))
    }
    
    private func _setURL(_ value:URL) throws {
        try _setValue(encoder.convert(value))
    }
    
    private func _setData(_ value:Data) throws {
        try _setValue(encoder.convert(value))
    }
    
    private struct SVECCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            return nil
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init(_ forValue:String) {
            self.stringValue = "keyless\(UUID())"
            self.intValue = nil
        }
        
        init(_ forValue:String, replacing bad:String, with good:String) {
            let cleaned = forValue.replacingOccurrences(of: bad, with: good)
            self.stringValue = "keyless_\(forValue)"
            self.intValue = nil
        }
    }
}

extension SimpleCoderSVEC: SingleValueEncodingContainer {

    var codingPath: [any CodingKey] { encoder.codingPath }

    func encodeNil() throws { try _setValue("NULL") }

    func encode(_ value: Bool) throws { try _setValue("\(value)") }

    func encode(_ value: String) throws { try _setValue(value) }

    func encode(_ value: Double) throws { try _setBinaryFloatingPoint(value) }

    func encode(_ value: Float) throws { try _setBinaryFloatingPoint(value) }

    func encode(_ value: Int) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: Int8) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: Int16) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: Int32) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: Int64) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: UInt) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: UInt8) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: UInt16) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: UInt32) throws { try _setFixedWidthInteger(value) }

    func encode(_ value: UInt64) throws { try _setFixedWidthInteger(value) }

    func encode<T>(_ value: T) throws where T: Encodable {
        print("encode<T> SV:", value)
        switch value {
        
//        case let value as UInt8: try encode(value)
//        case let value as Int8: try encode(value)
//        case let value as UInt16: try encode(value)
//        case let value as Int16: try encode(value)
//        case let value as UInt32: try encode(value)
//        case let value as Int32: try encode(value)
//        case let value as UInt64: try encode(value)
//        case let value as Int64: try encode(value)
//        case let value as Int: try encode(value)
//        case let value as UInt: try encode(value)
//        case let value as Float: try encode(value)
//        case let value as Double: try encode(value)
//        case let value as String: try encode(value)
//        case let value as Bool: try encode(value)
        
        case let value as Date: try _setDate(value)
        case let value as URL: try _setURL(value)
        case let value as Data: try _setData(value)
        default:
            try value.encode(to: encoder)
        }
    }
}
