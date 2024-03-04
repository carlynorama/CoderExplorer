//
//  File.swift
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

    private func _setValue(_ converted:String) throws { try try encoder.encode(converted, forKey: SVECCodingKey(converted)) }

    private func _setBinaryFloatingPoint(_ value: some BinaryFloatingPoint) throws {
        try _setValue(Double(value).description)
    }

    private func _setFixedWidthInteger(_ value: some FixedWidthInteger) throws {
        guard let validatedValue = Int(exactly: value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Integer out of range."))
        }
        try _setValue(validatedValue.description)
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
            self.stringValue = "keyless_\(forValue)"
            self.intValue = nil
        }
    }
}

extension SimpleCoderSVEC: SingleValueEncodingContainer {

    var codingPath: [any CodingKey] { encoder.codingPath }

    func encodeNil() throws {
        // Nil is encoded as no value.
    }

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
        switch value {
        case let value as UInt8: try encode(value)
        case let value as Int8: try encode(value)
        case let value as UInt16: try encode(value)
        case let value as Int16: try encode(value)
        case let value as UInt32: try encode(value)
        case let value as Int32: try encode(value)
        case let value as UInt64: try encode(value)
        case let value as Int64: try encode(value)
        case let value as Int: try encode(value)
        case let value as UInt: try encode(value)
        case let value as Float: try encode(value)
        case let value as Double: try encode(value)
        case let value as String: try encode(value)
        case let value as Bool: try encode(value)
        //case let value as Date: try _setValue(.date(value))
        default: try value.encode(to: encoder)
        }
    }
}
