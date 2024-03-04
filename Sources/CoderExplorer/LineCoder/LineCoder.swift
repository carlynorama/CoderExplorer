//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/27/24.
//

import Foundation


final class LineCoder  {
    var encoder: LMBasic = LMBasic(codingPath: [])
    
    public func encode<T: Encodable>(_ value: T) async throws -> Data {
        Data(try await encoder.encode(value))
    }
}

protocol LineEncoderProtocol: LineCoderProtocol & Encoder {}

protocol LineCoderProtocol {
    associatedtype Output:Hashable
    
    var includeHeaderRow:Bool? { get }
    
    var objectPrefix: Output { get }
    var objectSuffix: Output { get }
    var objectDelimiter: Output { get }
    var sortKeys: Bool { get }
    var keySorter: (Output, Output) -> Bool { get }
    var indexKeyedArrays:Bool { get }
    
    var itemPrefix: Output { get }
    var includeKeyInOutput:Bool { get }
    var showKeysForContainers:Bool { get }
    var keyDelimiter:Output { get }
    var keyValueDivider: Output { get }
    var itemSuffix: Output { get }
    var itemDelimiter: Output { get }
    
    var nullValueOutput:Output { get }
    var trueOutput: Output { get }
    var falseOutput: Output { get }
    var emptyOutput: Output { get }
    
    //Encoding
    var dateWrapper: (Date) throws -> LCEncoderData<Output>.LCEncodedValue { get }
    var dataWrapper: (Data) throws -> LCEncoderData<Output>.LCEncodedValue { get }
    var floatWrapper: (any FloatingPoint & CustomStringConvertible) throws -> LCEncoderData<Output>.LCEncodedValue { get }
    var stringWrapper: (any StringProtocol) throws -> LCEncoderData<Output>.LCEncodedValue { get }
    var intWrapper: (any FixedWidthInteger) throws -> LCEncoderData<Output>.LCEncodedValue { get }
    
    var genericWrapper: (Encodable, CodingKey?) throws -> LCEncoderData<Output>.LCEncodedValue? { get }
    
    var keyEncoder: (CodingKey?) throws -> Output { get }
    
    
    var writer: (LCEncoderData<Output>.LCEncodedValue) async throws -> Output { get }
    func encode<T: Encodable>(_: T) async throws -> Output
    
    var currentData:LCEncoderData<Output> { get }
    
    var encoderMaker:(CodingKey?) -> Self { get }
    
}

//TODO: went from struct to class b/c container could not be mutataing.
//Its from updating the WIP.
struct LMBasic:LineEncoderProtocol {
    
    
    typealias Output = [UInt8]
    typealias EncodedElement = LCEncoderData<[UInt8]>.LCEncodedValue
    
    init(codingPath:[CodingKey]) {
        self.codingPath = codingPath
    }
    
    
    var codingPath: [CodingKey]   // for Encoder Conformance
    var userInfo: [CodingUserInfoKey : Any] { [:] } // for Encoder Conformance
    
    var nullValueOutput: [UInt8] = [UInt8]._none
    var trueOutput: [UInt8] = [UInt8]._true
    var falseOutput: [UInt8] = [UInt8]._false
    var emptyOutput: [UInt8] = []
    
    var includeHeaderRow: Bool? = false
    var objectPrefix: [UInt8] = [UInt8._openbracket]
    var objectSuffix: [UInt8] = [UInt8._closebracket]
    var objectDelimiter: [UInt8] = [UInt8._newline]
    
    var includeKeyInOutput: Bool = true
    var showKeysForContainers: Bool = true
    var keyValueDivider: [UInt8] = [UInt8._colon]
    var keyDelimiter: [UInt8] = [UInt8._period]
    var sortKeys: Bool = true
    var keySorter: (Output, Output) -> Bool { basicKeySort }
    var indexKeyedArrays:Bool = true
    
    
    var itemPrefix: [UInt8] = []
    var itemSuffix: [UInt8] = []
    var itemDelimiter: [UInt8] = [UInt8._comma]
    
    var dateWrapper: (Date) throws -> EncodedElement { wrapDate }
    var dataWrapper: (Data) throws -> EncodedElement  { wrapData }
    
    var floatWrapper: (any FloatingPoint & CustomStringConvertible) throws -> EncodedElement { wrapFloat }
    var stringWrapper: (any StringProtocol) throws -> EncodedElement { wrapString }
    var intWrapper: (any FixedWidthInteger) throws -> EncodedElement { wrapInt }
    var genericWrapper: (Encodable, CodingKey?) throws -> EncodedElement? { wrapEncodable }
    
    //var keyEncoder: (CodingKey?) throws -> Output { noChainKey }
    var keyEncoder: (CodingKey?) throws -> Output { chainedKey }
    
    var writer: (EncodedElement) async throws -> Output {
        writeValue
    }
    
    var currentData:LCEncoderData = LCEncoderData<Output>()
    
    var encoderMaker:(CodingKey?) -> Self { getEncoder }
    

    
    
    //compare JSONEncoder.swift 235.
    func encode<T: Encodable>(_ value: T) async throws -> Output {
        let encodedObject:EncodedElement = try encodeElement(value)
        return try await writer(encodedObject)
    }
    
    func encodeElement<T: Encodable>(_ value: T) throws -> EncodedElement {
        //THIS object is the encoder. This call is the top level rest if needed.
        //compare JSONEncoder.swift 235.
        currentData.current = nil
        if let encodedObject  = try wrapEncodable(value, additionalKey: nil) {
            return encodedObject
        }
        else { throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }
    }
    
    func wrapEncodable(_ encodable: Encodable, additionalKey: CodingKey?) throws -> EncodedElement? {
        
        //Additional key is an auto sub coder to keep the coding path sane.
        //different than JSONEncoder.
        //MARK: New Encoder
        if let additionalKey {
            print("new encoder for  \(additionalKey):\(encodable)")
            let encoder = getEncoder(for: additionalKey)
            try encodable.encode(to: encoder)
            return encoder.currentData.value
        }
        
        switch encodable {
        case let date as Date:
            return try dateWrapper(date)
        case let data as Data:
            return try dataWrapper(data)
        case let number as any FixedWidthInteger:
            return try intWrapper(number)
        case let url as URL:
            return .string(Output(url.absoluteString.utf8))
        case let decimal as Decimal:
            return .number(Output(decimal.description.utf8))
        case let string as any StringProtocol:
            return try stringWrapper(string)
        default:
            print("default wrapEncodable happened. \(encodable), \(self.codingPath)")
            //let encoder = getEncoder(for: additionalKey)
            try encodable.encode(to: self)
            return currentData.value
        }
    }
    
    
    //MARK: Protocol Implementations
    
    func basicKeySort(lhs:Output, rhs:Output) -> Bool {
        String(bytes:lhs, encoding: .utf8)!.compare(String(bytes: rhs, encoding: .utf8)!, options: [.caseInsensitive, .diacriticInsensitive, .forcedOrdering, .numeric, .widthInsensitive]) == .orderedAscending
    }
    
    func wrapDate(_ date:Date) -> EncodedElement {
        //TODO: handle additional key.
        return .string(Output(_iso8601Formatter.string(from: date).utf8))
    }
    
    internal var _iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    //TODO: Just use the raw bytes?
    func wrapData(_ data:Data) -> EncodedElement {
        let base64 = data.base64EncodedString()
        return .string(Output(base64.utf8))
    }
    
    func wrapFloat(_ float:any FloatingPoint & CustomStringConvertible) -> EncodedElement {
        var string = float.description
        if string.hasSuffix(".0") {
            string.removeLast(2)
        }
        return .number(Output(string.utf8))
    }
    
    func wrapString(_ string:any StringProtocol) -> EncodedElement {
        .string(Output(String(string).utf8))
    }
    
    func wrapInt(_ value:any FixedWidthInteger) -> EncodedElement {
        .number(Output(value.description.utf8))
    }
    
    func noChainKey(_ key:CodingKey?) throws -> [UInt8] {
        return [UInt8](key?.stringValue.utf8 ?? "".utf8)
    }
    
    func chainedKey(_ key:CodingKey?) throws -> [UInt8] {
        var allKeys:[CodingKey] = codingPath
        if let key {
            allKeys.append(key)
        }
        if let sep = String(bytes: keyDelimiter, encoding: .utf8) {
            let string = allKeys.compactMap { $0.stringValue }.joined(separator: sep)
            return [UInt8](string.utf8)
        } else {
            throw EncodingError.invalidValue(keyDelimiter, EncodingError.Context(codingPath: allKeys, debugDescription: "Could not encode codingPath to key with delimiter."))
        }
    }
    
    //MARK: Writer
    //Moved from being inside EncodedElement type.
    func writeValue(_ value: EncodedElement) -> Output {
        var bytes = Output()
        //options handled
        self.writeValue(value, into: &bytes)
        return bytes
    }
    
    private func writeValue(_ value: EncodedElement, into bytes: inout Output, depth:Int = 0) {
        switch value {
        case .null:
            bytes.append(contentsOf: nullValueOutput)
        case .bool(true):
            bytes.append(contentsOf: trueOutput)
        case .bool(false):
            bytes.append(contentsOf: falseOutput)
        case .string(let encoded):
            bytes.append(contentsOf: encoded)
        case .number(let encoded):
            bytes.append(contentsOf: encoded)
        case .array(let array):
            writeArray(array, into: &bytes, depth:depth)
        case .object(let dict):
            if sortKeys {
                let sorted = dict.sorted { keySorter($0.key, $1.key) }
                self.writeObject(sorted, into: &bytes, depth: depth + 1)
            } else {
                writeObject(dict, into: &bytes, depth: depth + 1)
            }
            //            }
        }
    }
    
    func writeArray<Object: Sequence>(_ array: Object, into bytes: inout Output, depth: Int = 0)
    where Object.Element == EncodedElement
    {
        let flip = depth > 0
        let prefix = flip ?   objectPrefix : emptyOutput
        let suffix = flip ?   objectSuffix : emptyOutput
        let delimiter = flip ?   itemDelimiter : objectDelimiter
        
        var iterator = array.makeIterator()
        bytes.append(contentsOf:prefix)
        if let first = iterator.next() {
            writeItem(value:first)
        }
        while let item = iterator.next() {
            bytes.append(contentsOf:delimiter)
            writeItem(value:item)
        }
        bytes.append(contentsOf:suffix)
        
        
        func writeItem(value:EncodedElement) {
            self.writeValue(value, into: &bytes, depth: depth)
        }
    }
    
    func writeObject<Object: Sequence>(_ object: Object, into bytes: inout Output, depth: Int = 0)
    where Object.Element == (key: Output, value: EncodedElement)
    {
        
        var iterator = object.makeIterator()
        bytes.append(contentsOf:objectPrefix)
        if let (key, value) = iterator.next() {
            writeItem(key: key, value: value)
        }
        while let (key, value) = iterator.next() {
            bytes.append(contentsOf:itemDelimiter)
            writeItem(key: key, value: value)
        }
        bytes.append(contentsOf:objectSuffix)
        
        func writeItem(key:Output, value:EncodedElement) {
            if includeKeyInOutput {
                if showKeysForContainers || value.isValue {
                    bytes.append(contentsOf: key)
                    bytes.append(contentsOf: keyValueDivider)
                }
            }
            self.writeValue(value, into: &bytes, depth: depth)
        }
    }
    
}

extension LMBasic:Encoder {
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(LineEncoderKEC(encoderInstance: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        print("Unkeyed!!")
        if indexKeyedArrays {
            return LineEncoderIKUEC(encoderInstance: self)
        } else {
            return LineEncoderUEC(encoderInstance: self)
        }
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return LineEncoderSVEC(encoderInstance: self)
    }
    
    //TODO: See struct -> class problem.
    func getEncoder(for additionalKey: CodingKey?) -> Self {
        if let additionalKey = additionalKey {
            var newCodingPath = self.codingPath
            newCodingPath.append(additionalKey)
            return Self(codingPath: newCodingPath)
        }
        
        //Its the settings not the data that should be passed?
        //TODO: The nesting dilema.
        var copy = self
        copy.currentData = LCEncoderData()
        return copy
        //return self
    }
}


//MARK: SingleValueEncoder
private struct LineEncoderSVEC<LE: LineEncoderProtocol>: SingleValueEncodingContainer {
    
    var encoderInstance: LE
    var codingPath: [CodingKey] {
        encoderInstance.codingPath
    }
    
    mutating func encodeNil() throws {
        try self.encoderInstance.currentData.update(.null)
    }
    
    mutating func encode(_ value: Bool) throws {
        try self.encoderInstance.currentData.update(.bool(value))
    }
    
    mutating func encode(_ value: String) throws {
        try self.encoderInstance.currentData.update(try encoderInstance.stringWrapper(value))
    }
    
    mutating func encode(_ value: Double) throws {
        try encodeFloatingPoint(value)
    }
    
    mutating func encode(_ value: Float) throws {
        try encodeFloatingPoint(value)
    }
    
    mutating func encode(_ value: Int) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }
    
    //MARK: encode<T> SVEC
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        fatalError()
    }
    
}

extension LineEncoderSVEC {
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
        //self.preconditionCanEncodeNewValue()
        try self.encoderInstance.currentData.update(encoderInstance.intWrapper(value))
    }
    
    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
        //self.preconditionCanEncodeNewValue()
        try self.encoderInstance.currentData.update(encoderInstance.floatWrapper(float))
    }
}



fileprivate struct LineEncoderKEC<Key: CodingKey, LE: LineEncoderProtocol>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] {
        encoderInstance.codingPath
    }
    
    var encoderInstance: LE
    
    mutating func encodeNil(forKey key: Key) throws {
        try encoderInstance.currentData.update(.null, for: try encoderInstance.keyEncoder(key))
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try encoderInstance.currentData.update(.bool(value), for: try encoderInstance.keyEncoder(key))
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try encoderInstance.currentData.update(encoderInstance.stringWrapper(value), for: try encoderInstance.keyEncoder(key))
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        try encodeFloatingPoint(value, key: key)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        try encodeFloatingPoint(value, key: key)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: key)
    }
    
    //MARK: encode<T> KEC
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard let encoded = try encoderInstance.genericWrapper(value, key) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Could not encocode \(value)"))
        }
        try encoderInstance.currentData.update(encoded, for: encoderInstance.keyEncoder(key))
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
        //        let newEncoder = encoderInstance.encoderMaker(key)
        //        let nestedContainer = KeyedEncodingContainer(LineEncoderKEC<NestedKey, LE>(encoderInstance: newEncoder))
        //        return nestedContainer
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
        //        let newEncoder = encoderInstance.encoderMaker(key)
        //        let nestedContainer = LineEncoderUEC(encoderInstance: newEncoder)
        //        return nestedContainer
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError()
        //TODO
        //encoderInstance.encoderMaker(_LCKey.super)
        //or just
        //encoderInstance
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
        //encoderInstance.encoderMaker(key)
    }
    
    
}

extension LineEncoderKEC {
    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F, key: Key) throws {
        try encoderInstance.currentData.update(encoderInstance.floatWrapper(float), for:try encoderInstance.keyEncoder(key))
    }
    
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N, key: Key) throws {
        try encoderInstance.currentData.update(encoderInstance.intWrapper(value), for: try encoderInstance.keyEncoder(key))
    }
}


fileprivate struct LineEncoderUEC<LE: LineEncoderProtocol>:UnkeyedEncodingContainer {
    var codingPath: [CodingKey] {
        encoderInstance.codingPath
    }
    
    var encoderInstance: LE
    var count: Int = 0
    
    mutating func encodeNil() throws {
        try encoderInstance.currentData.append(.null)
    }
    
    mutating func encode(_ value: Bool) throws {
        try encoderInstance.currentData.append(.bool(value))
    }
    
    mutating func encode(_ value: String) throws {
        try encoderInstance.currentData.append(encoderInstance.stringWrapper(value))
    }
    
    mutating func encode(_ value: Double) throws {
        try encodeFloatingPoint(value)
    }
    
    mutating func encode(_ value: Float) throws {
        try encodeFloatingPoint(value)
    }
    
    mutating func encode(_ value: Int) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }
    
    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }
    
    //MARK: encode<T> UEC
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = encoderInstance.encoderMaker(nil)
        try value.encode(to: encoder)
        if let value = encoder.currentData.value {
            try encoderInstance.currentData.append(value)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Could not encocode \(value)"))
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
        //        let codingKey = IndexedCodingKey(intValue: count)!
        //        let newEncoder = encoderInstance.encoderMaker(codingKey)
        //        let nestedContainer = LineEncoderKEC<NestedKey, LE>(encoderInstance: newEncoder)
        //        return KeyedEncodingContainer(nestedContainer)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
        //        let codingKey = IndexedCodingKey(intValue: count)!
        //        let newEncoder = encoderInstance.encoderMaker(codingKey)
        //        let nestedContainer = LineEncoderUEC(encoderInstance: newEncoder )
        //        return nestedContainer
    }
    
    //TODO: Should this be the IndexKey instead?
    mutating func superEncoder() -> Encoder {
        fatalError()
        //encoderInstance.encoderMaker(_LCKey.super)
    }
    
    
}

extension LineEncoderUEC {
    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
        try encoderInstance.currentData.append(encoderInstance.floatWrapper(float))
    }
    
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
        try encoderInstance.currentData.append(encoderInstance.intWrapper(value))
    }
}


fileprivate struct LineEncoderIKUEC<LE: LineEncoderProtocol>:UnkeyedEncodingContainer {
    var codingPath: [CodingKey] {
        encoderInstance.codingPath
    }
    
    var encoderInstance: LE
    private(set) var count: Int = 0
    
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
    
    
    
    // TODO: LineCoder does not currently have a way to force single values to remember the coding path they rode in on.
    //Making that feature available would be good.
    //here are some options in the mean time for working with adding indexes to arrays.
    //Would be nice to add a depth level detection?
    
    
    @inlinable
    mutating func encodeThis(_ value: Encodable) throws {
        try defaultKeyBehavior(value)
    }
    
    //keyed things get indexes shown. single values do not.
    //"howdy\nhowdy\nhowdy\nhowdy\nhowdy"
//    "[0.array:[54,45,67,89],0.numeral:4314124,0.string:world]
//    [1.array:[54,45,67,89],1.numeral:4314124,1.string:world]
//    [2.array:[54,45,67,89],2.numeral:4314124,2.string:world]
//    [3.array:[54,45,67,89],3.numeral:4314124,3.string:world]
//    [4.array:[54,45,67,89],4.numeral:4314124,4.string:world]"
    @inlinable
     mutating func defaultKeyBehavior<T>(_ value: T) throws where T : Encodable {
        let codingKey = nextIndexedKey()
        //this will make the call to getEncoder for me.
        let encoded = try encoderInstance.genericWrapper(value, codingKey)
        try encoderInstance.currentData.append(encoded ?? .null)
    }
    
    //"[0.0:howdy]\n[1.1:howdy]\n[2.2:howdy]\n[3.3:howdy]\n[4.4:howdy]"
//    "[0.0:[0.0.array:[[0.0.array.0.0:54],[0.0.array.1.1:45],[0.0.array.2.2:67],[0.0.array.3.3:89]],0.0.numeral:4314124,0.0.string:world]]
//    [1.1:[1.1.array:[[1.1.array.0.0:54],[1.1.array.1.1:45],[1.1.array.2.2:67],[1.1.array.3.3:89]],1.1.numeral:4314124,1.1.string:world]]
//    [2.2:[2.2.array:[[2.2.array.0.0:54],[2.2.array.1.1:45],[2.2.array.2.2:67],[2.2.array.3.3:89]],2.2.numeral:4314124,2.2.string:world]]
//    [3.3:[3.3.array:[[3.3.array.0.0:54],[3.3.array.1.1:45],[3.3.array.2.2:67],[3.3.array.3.3:89]],3.3.numeral:4314124,3.3.string:world]]
//    [4.4:[4.4.array:[[4.4.array.0.0:54],[4.4.array.1.1:45],[4.4.array.2.2:67],[4.4.array.3.3:89]],4.4.numeral:4314124,4.4.string:world]]"
    
    @inlinable
    mutating func forceKeyNDict<T>(_ value: T) throws where T : Encodable {
        let dict = [count:value]
        let codingKey = nextIndexedKey()
        //this will make the call to getEncoder for me.
        let encoded = try encoderInstance.genericWrapper(dict, codingKey)
        try encoderInstance.currentData.append(encoded ?? .null)
    }
    
    //"[0:howdy]\n[1:howdy]\n[2:howdy]\n[3:howdy]\n[4:howdy]"
    //"[0:[0.array:[[0.array.0:54],[0.array.1:45],[0.array.2:67],[0.array.3:89]],0.numeral:4314124,0.string:world]]
    //[1:[1.array:[[1.array.0:54],[1.array.1:45],[1.array.2:67],[1.array.3:89]],1.numeral:4314124,1.string:world]]
    //[2:[2.array:[[2.array.0:54],[2.array.1:45],[2.array.2:67],[2.array.3:89]],2.numeral:4314124,2.string:world]]
    //[3:[3.array:[[3.array.0:54],[3.array.1:45],[3.array.2:67],[3.array.3:89]],3.numeral:4314124,3.string:world]]
    //[4:[4.array:[[4.array.0:54],[4.array.1:45],[4.array.2:67],[4.array.3:89]],4.numeral:4314124,4.string:world]]"
    @inlinable
    mutating func forceCountDictOnly<T>(_ value: T) throws where T : Encodable {
        let dict = [count:value]
        let _ = nextIndexedKey()
        
        let encoder = encoderInstance.encoderMaker(nil)
        try dict.encode(to: encoder)
        if let encValue = encoder.currentData.value {
            try encoderInstance.currentData.append(encValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Could not encocode \(value)"))
        }
    }
    
    
    mutating func encodeNil() throws {
        try encoderInstance.currentData.append(.null)
    }
    
    mutating func encode(_ value: Bool) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: String) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Double) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Float) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Int) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Int8) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Int16) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Int32) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: Int64) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: UInt) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: UInt8) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: UInt16) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: UInt32) throws {
        try self.encodeThis(value)
    }
    
    mutating func encode(_ value: UInt64) throws {
        try self.encodeThis(value)
    }
    
    //MARK: encode<T> IKUEC
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try self.encodeThis(value)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
        //        let codingKey = IndexedCodingKey(intValue: count)!
        //        let newEncoder = encoderInstance.encoderMaker(codingKey)
        //        let nestedContainer = LineEncoderKEC<NestedKey, LE>(encoderInstance: newEncoder)
        //        return KeyedEncodingContainer(nestedContainer)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
        //        let codingKey = IndexedCodingKey(intValue: count)!
        //        let newEncoder = encoderInstance.encoderMaker(codingKey)
        //        let nestedContainer = LineEncoderUEC(encoderInstance: newEncoder )
        //        return nestedContainer
    }
    
    //TODO: Should this be the IndexKey instead?
    mutating func superEncoder() -> Encoder {
        fatalError()
        //encoderInstance.encoderMaker(_LCKey.super)
    }
    
    
}

extension LineEncoderIKUEC {
    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
        try encoderInstance.currentData.append(encoderInstance.floatWrapper(float))
    }
    
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
        try encoderInstance.currentData.append(encoderInstance.intWrapper(value))
    }
}


//internal struct _LCKey: CodingKey {
//    var stringValue: String
//    
//    init?(stringValue: String) {
//        <#code#>
//    }
//    
//    var intValue: Int?
//    
//    init?(intValue: Int) {
//        <#code#>
//    }
//    
////    public var stringValue: String
////    public var intValue: Int?
////
////    public init?(stringValue: String) {
////        self.stringValue = stringValue
////        self.intValue = nil
////    }
////
////    public init?(intValue: Int) {
////        self.stringValue = "\(intValue)"
////        self.intValue = intValue
////    }
////
////    public init(stringValue: String, intValue: Int?) {
////        self.stringValue = stringValue
////        self.intValue = intValue
////    }
////
////    internal init(index: Int) {
////        self.stringValue = "Index \(index)"
////        self.intValue = index
////    }
////
////    internal static let `super` = _LCKey(stringValue: "super")!
//}
