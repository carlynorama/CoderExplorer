//
//  File.swift
//  
//
//  Created by Carlyn Maw on 3/4/24.
//

import Foundation


struct SimpleCoderUEC {

    /// The associated encoder.
    let encoder: _SimpleEncoder
    private(set) var count: Int = 0
}

extension SimpleCoderUEC {

    private mutating func _appendValue(_ converted:String) throws {
        try encoder.encode(converted, forKey: nextIndexedKey())
    }


    /// Appends the provided value as a node to the underlying array.
    /// - Parameter value: The value to append.
    /// - Throws: An error if appending the node to the underlying array fails.
    private mutating func _appendBinaryFloatingPoint(_ value: some BinaryFloatingPoint) throws {
        try _appendValue(Double(value).description)
    }

    /// Appends the provided value as a node to the underlying array.
    /// - Parameter value: The value to append.
    /// - Throws: An error if appending the node to the underlying array fails.
    private mutating func _appendFixedWidthInteger(_ value: some FixedWidthInteger) throws {
        guard let validatedValue = Int(exactly: value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Integer out of range."))
        }
        try _appendValue(validatedValue.description)
    }
}

extension SimpleCoderUEC: UnkeyedEncodingContainer {

    var codingPath: [any CodingKey] { encoder.codingPath }

    private mutating func nextIndexedKey() -> CodingKey {
        let nextCodingKey = IndexedCodingKey(intValue: count)!
        count += 1
        return nextCodingKey
    }
    
    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = intValue.description
        }

        init?(stringValue: String) {
            return nil
        }
    }

    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer { encoder.unkeyedContainer() }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
    where NestedKey: CodingKey { encoder.container(keyedBy: NestedKey.self) }

    mutating func superEncoder() -> any Encoder { encoder }

    mutating func encodeNil() throws { fatalError() }

    mutating func encode(_ value: Bool) throws { try _appendValue("\(value)") }

    mutating func encode(_ value: String) throws { try _appendValue(value) }

    mutating func encode(_ value: Double) throws { try _appendBinaryFloatingPoint(value) }

    mutating func encode(_ value: Float) throws { try _appendBinaryFloatingPoint(value) }

    mutating func encode(_ value: Int) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: Int8) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: Int16) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: Int32) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: Int64) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: UInt) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: UInt8) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: UInt16) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: UInt32) throws { try _appendFixedWidthInteger(value) }

    mutating func encode(_ value: UInt64) throws { try _appendFixedWidthInteger(value) }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
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
        //case let value as Date: try _appendValue(.date(value))
        default:
            var tmpEncoder = _SimpleEncoder(data:encoder.data)
            tmpEncoder.codingPath = encoder.codingPath
            tmpEncoder.codingPath.append(nextIndexedKey())
            try value.encode(to: tmpEncoder)
        }
    }
}
