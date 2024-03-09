//
//  SimpleCoder.swift
//
//
//  Created by Carlyn Maw on 3/3/24.
//

import Foundation


struct SimpleCoder {
    let flaggedTypes:[Encodable.Type] = [Date.self, URL.self, Data.self]
    public func encode<E:Encodable>(_ value: E) throws -> String {
        let encoder = _SimpleEncoder()
        if flaggedTypes.contains(where: { $0 == E.self }) {
            try encoder.specialEncoder(for: value)
        } else {
            try value.encode(to: encoder)
        }
        return encoder.value
    }
}


final class SimpleCoderData<Value> {
    var storage:Value
    
    init(_ value: Value) {
        self.storage = value
    }
}

struct _SimpleEncoder {
    var data:SimpleCoderData<[String: String]>
    var codingPath: [CodingKey] = []
    
    var value:String {
        var lines = data.storage.map { key, value in
            if key.isEmpty || key.contains("keyless"){
                print("found a keyless with key \(key)")
                return "\(value)"
            } else {
                return "\(key):\(value)"
            }
        }
        lines.sort()
        lines.insert(contentsOf: processUserInfo(), at: 0)
        return lines.joined(separator: "/")
    }
    
    func processUserInfo() -> [String] {
        return []
    }
}

extension _SimpleEncoder {
    init() {
        self.data = SimpleCoderData([:])
    }
}

extension _SimpleEncoder {
    
    func encodeKey(key:CodingKey) -> String {
        (codingPath + [key]).map { $0.stringValue }.joined(separator: ".")
    }
    
    //called from containers
    func encode(_ value: String, forKey key:CodingKey) {
        data.storage[encodeKey(key: key)] = value
    }
    
    func specialEncoder(for value: some Encodable) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }
}

extension _SimpleEncoder {
    
    //called from the containers
    
    @inline(__always)
    func convert(_ value: some BinaryFloatingPoint) throws -> String {
        Double(value).description
    }
    
    @inline(__always)
    func convert(_ value: some FixedWidthInteger) throws -> String {
        guard let validatedValue = Int(exactly: value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Integer out of range."))
        }
        return validatedValue.description
    }
    
    @inline(__always)
    func convert(_ value:Date) throws -> String {
        return value.ISO8601Format()
    }
    
    @inline(__always)
    func convert(_ value:URL) throws -> String {
        return value.absoluteString
    }
    
    @inline(__always)
    func convert(_ value:Data) throws -> String {
        return value.base64EncodedString()
    }
}

extension _SimpleEncoder:Encoder {
    
    var userInfo: [CodingUserInfoKey : Any] { [:] }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(SimpleEncoderKEC<Key>(encoder: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        SimpleCoderUEC(encoder: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        SimpleCoderSVEC(encoder: self)
    }
    
    
}




