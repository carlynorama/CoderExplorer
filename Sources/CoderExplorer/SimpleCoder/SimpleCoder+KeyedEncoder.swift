//
//  SimpleCoder+KeyedEncoder.swift
//  
//
//  Created by Carlyn Maw on 3/4/24.
//

import Foundation




struct SimpleEncoderKEC<Key: CodingKey> {
    let encoder: _SimpleEncoder
}


extension  SimpleEncoderKEC {
    private func _insertValue(_ converted:String, atKey key: Key) throws {
        try encoder.encode(converted, forKey: key)
    }

//    private func _insertValue(_ convertible: some CustomStringConvertible, atKey key: Key) throws {
//        try _insertValue(convertible.description, atKey: key)
//    }

    private func _insertBinaryFloatingPoint(_ value: some BinaryFloatingPoint, atKey key: Key) throws {
        try _insertValue(encoder.convert(value), atKey: key)
    }


    private func _insertFixedWidthInteger(_ value: some FixedWidthInteger, atKey key: Key) throws {
        try _insertValue(encoder.convert(value), atKey: key)
    }
    
    private func _insertDate(_ value: Date, atKey key:Key) throws {
        try _insertValue(encoder.convert(value), atKey: key)
    }
    
    private func _insertURL(_ value: URL, atKey key:Key) throws {
        try _insertValue(encoder.convert(value), atKey: key)
    }
    
    private func _insertData(_ value: Data, atKey key:Key) throws {
        let result = try encoder.convert(value)
        print(result)
        try _insertValue(result, atKey: key)
    }
}

extension SimpleEncoderKEC:KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] {
        encoder.codingPath
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        //for now... do nothing.
        //try _insertValue("NULL", atKey: key)
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try _insertValue("\(value)", atKey: key)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try _insertValue(value, atKey: key)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        try _insertBinaryFloatingPoint(value, atKey: key)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        try _insertBinaryFloatingPoint(value, atKey: key)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: Int8, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: Int16, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: Int32, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: Int64, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: UInt, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: UInt8, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: UInt16, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: UInt32, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode(_ value: UInt64, forKey key: Key) throws { try _insertFixedWidthInteger(value, atKey: key) }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        print("encode<T> Keyed:", value)
        switch value {
//        case let value as UInt8: try encode(value, forKey: key)
//        case let value as Int8: try encode(value, forKey: key)
//        case let value as UInt16: try encode(value, forKey: key)
//        case let value as Int16: try encode(value, forKey: key)
//        case let value as UInt32: try encode(value, forKey: key)
//        case let value as Int32: try encode(value, forKey: key)
//        case let value as UInt64: try encode(value, forKey: key)
//        case let value as Int64: try encode(value, forKey: key)
//        case let value as Int: try encode(value, forKey: key)
//        case let value as UInt: try encode(value, forKey: key)
//        case let value as Float: try encode(value, forKey: key)
//        case let value as Double: try encode(value, forKey: key)
//        case let value as String: try encode(value, forKey: key)
//        case let value as Bool: try encode(value, forKey: key)
        case let value as Date: try _insertDate(value, atKey: key)
        case let value as URL: try _insertURL(value, atKey: key)
        case let value as Data: try _insertData(value, atKey: key)
//        //catches too much for now.
//       case let value as CustomStringConvertible: try _insertValue(value, atKey: key)
//            
        default:
            //points to same data reference! 
            var tmpEncoder = encoder.getEncoder(forKey: key, withData: encoder.data)
            try value.encode(to: tmpEncoder)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
        -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
        //print("nestedKey:\(key.stringValue)")
        var tmpEncoder =  encoder.getEncoder(forKey: key, withData: encoder.data)
        return tmpEncoder.container(keyedBy: NestedKey.self)
        
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        fatalError()
        var tmpEncoder =  encoder.getEncoder(forKey: key, withData: encoder.data)
        return tmpEncoder.unkeyedContainer()
        
    }

    mutating func superEncoder() -> any Encoder {
        //TODO: Push this lack of nested key?
        encoder
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        let tmpEncoder =  encoder.getEncoder(forKey: key, withData: encoder.data)
        return tmpEncoder
    }
}
