//
//  SimpleCoder+UnkeyedEncoder.swift
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
        try _appendValue(encoder.convert(value))
    }

    /// Appends the provided value as a node to the underlying array.
    /// - Parameter value: The value to append.
    /// - Throws: An error if appending the node to the underlying array fails.
    private mutating func _appendFixedWidthInteger(_ value: some FixedWidthInteger) throws {
        try _appendValue(encoder.convert(value))
    }
    
    private mutating func _appendDate(_ value:Date) throws {
        try _appendValue(encoder.convert(value))
    }
    
    private mutating func _appendURL(_ value:URL) throws {
        try _appendValue(encoder.convert(value))
    }
    
    private mutating func _appendData(_ value:Data) throws {
        try _appendValue(encoder.convert(value))
    }
    
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
}

extension SimpleCoderUEC: UnkeyedEncodingContainer {

    var codingPath: [any CodingKey] { encoder.codingPath }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        fatalError()
        let tmpEncoder =  encoder.getEncoder(forKey: nextIndexedKey(), withData: encoder.data)
        return tmpEncoder.unkeyedContainer()
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
    where NestedKey: CodingKey {
        fatalError()
        var tmpEncoder =  encoder.getEncoder(forKey: nextIndexedKey(), withData: encoder.data)
        return tmpEncoder.container(keyedBy: NestedKey.self)
    }

    mutating func superEncoder() -> any Encoder {
        let tmpEncoder =  encoder.getEncoder(forKey: nextIndexedKey(), withData: encoder.data)
        return tmpEncoder
    }

    mutating func encodeNil() throws {
        //nothing seems to land here. All going through SVEC.
        fatalError()
        //try _appendValue("NULL")
    }

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
        print("encode<T> Unkeyed:", value)
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
        case let value as Date: try _appendDate(value)
        case let value as URL: try _appendURL(value)
        case let value as Data: try _appendData(value)
        default:
            //points to same data reference! 
           var tmpEncoder = encoder.getEncoder(forKey: nextIndexedKey(), withData: encoder.data)
            try value.encode(to: tmpEncoder)
        }
    }
}
