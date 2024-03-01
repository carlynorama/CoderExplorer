//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/25/24.
//  https://talk.objc.io/episodes/S01E348-routing-with-codable-encoding
//https://github.com/objcio/S01E348-routing-with-codable-encoding/blob/main/Sources/CodableRouting/Encoding.swift

import Foundation

enum Route: Codable, Hashable {
    case home
    case profile(Int)
    case nested(NestedRoute?)
}

enum NestedRoute: Codable, Hashable {
    case foo
}

enum RouterError:Error {
    case decoderError
    case encoderError
}

enum Router {
    static public func encode<Value: Encodable>(_ value:Value) throws -> String {
        let encoder = RouteEncoder(components: Box([]))
        try value.encode(to: encoder)
        let path = encoder.components.value.joined(separator: "/")
        return "/\(path)"
    }
    
    static public func decode<R: Decodable>(_ path: String) throws -> R {
        guard path.first == "/" else { throw RouterError.decoderError }
        let components = path.dropFirst()
            .split(separator: "/", omittingEmptySubsequences: false)
            .map {String($0)}
        let decoder = RouteDecoder(components: Box(components))
        return try R.init(from: decoder)
    }
}

struct RouteEncoder: Encoder {
    var components: Box<[String]>
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    //dictionary/enum type
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(RouteKEC(components:components))
    }
    
    //array type
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
    
    
}

final class Box<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

//When you for the KeyedEncodingContainerProtocol it does the auto complete.
struct RouteKEC<Key:CodingKey> :KeyedEncodingContainerProtocol {
    var components: Box<[String]>
    
    var codingPath: [CodingKey] { [] }
    
    mutating func encodeNil(forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        components.value.append("\(value)")
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        fatalError()
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        fatalError()
    }
    
    //called anytime non-primitive value
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        //case nested(NestedRoute?) example
        //print(key) // NestedCodingKeys(stringValue: "_0", intValue: nil)
         let encoder = RouteEncoder(components: components)
        try value.encode(to: encoder)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        components.value.append(key.stringValue)
        return KeyedEncodingContainer(RouteKEC<NestedKey>(components: components))
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError()
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
    
    
}


struct RouteDecoder:Decoder {
    var components: Box<[String]>
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer(RouteKDC(components: components))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
    
    
}


struct RouteKDC<Key:CodingKey>:KeyedDecodingContainerProtocol {
    var components: Box<[String]>
    var codingPath: [CodingKey] { [] }
    var allKeys: [Key] = []
    
    init(components: Box<[String]>) {
        self.components = components
        if let c = components.value.first,
            let k = Key(stringValue: c) {
            self.components.value.removeFirst()
            allKeys = [k]
        }
        
    }
    

    
    func contains(_ key: Key) -> Bool {
        //print(key)
        //NestedCodingKeys(stringValue: "_0", intValue: nil)
        if key.stringValue.hasPrefix("_") {
            return true
        }
        return false
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return components.value.isEmpty
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        fatalError()
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        fatalError()
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        fatalError()
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        fatalError()
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let f = components.value.first,
              let i = Int(f) else {
            throw RouterError.decoderError
        }
        return i
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        fatalError()
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        fatalError()
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        fatalError()
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        fatalError()
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        fatalError()
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        fatalError()
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        fatalError()
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        fatalError()
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        fatalError()
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let decoder = RouteDecoder(components: components)
        return try T(from:decoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(RouteKDC<NestedKey>(components: components))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func superDecoder() throws -> Decoder {
        fatalError()
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
    
    
}
