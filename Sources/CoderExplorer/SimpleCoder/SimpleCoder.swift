//
//  File.swift
//  
//
//  Created by Carlyn Maw on 3/3/24.
//

import Foundation


struct SimpleCoder {
    static public func encode(_ value: Encodable) throws -> String {
        let encoder = _SimpleEncoder()
        try value.encode(to: encoder)
        return encoder.value
    }
    
}


class SimpleCoderData<Value> {
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
            if key.isEmpty {
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
    
    func encode(_ value: String, forKey key:CodingKey) {
        data.storage[encodeKey(key: key)] = value
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
        fatalError()
    }
    
    
}




