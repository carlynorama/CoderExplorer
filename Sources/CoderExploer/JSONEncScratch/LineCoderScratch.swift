////
////  File.swift
////
////
////  Created by Carlyn Maw on 2/26/24.
////  https://github.com/apple/swift-corelibs-foundation/blob/806ba24a520a7803bfb3145d5706480fca41f38c/Sources/Foundation/JSONEncoder.swift#L27
////https://github.com/apple/swift-corelibs-foundation/blob/5a1db791ab824e29dc45ce08f729d3541f0517d0/Sources/Foundation/JSONSerialization%2BParser.swift#L635
//
//import Foundation
//
//fileprivate protocol _DictionaryIsEncodableMarker { }
//extension Dictionary: _DictionaryIsEncodableMarker where Key == String, Value: Encodable { }
//
//fileprivate protocol LCEncoder {
//    var codingPath: [CodingKey] { get }
//    var options: LineMaker._Options { get }
//    var encoderInstance: LineEncoderImplementation  { get }
//}
//
//
//final class LineMaker {
//    
//    //Confif
//    /// The output format to produce. Defaults to `[]`.
//    //open var outputFormatting: OutputFormatting = []
//    
//    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
//    var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
//    
//    /// The strategy to use in encoding binary data. Defaults to `.base64`.
//    var dataEncodingStrategy: DataEncodingStrategy = .base64
//    
//    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
//    var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
//    
//    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
//    var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
//    
//    /// Contextual user-provided information for use during encoding.
//    var userInfo: [CodingUserInfoKey: Any] = [:]
//    
//    /// Options set on the top-level encoder to pass down the encoding hierarchy.
//    internal struct _Options {
//        let constants:Constants = Constants()
//        let dateEncodingStrategy: DateEncodingStrategy
//        let dataEncodingStrategy: DataEncodingStrategy
//        let nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
//        let keyEncodingStrategy: KeyEncodingStrategy
//        let userInfo: [CodingUserInfoKey: Any]
//    }
//    
//    /// The options set on the top-level encoder.
//    internal var options: _Options {
//        return _Options(dateEncodingStrategy: dateEncodingStrategy,
//                        dataEncodingStrategy: dataEncodingStrategy,
//                        nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
//                        keyEncodingStrategy: keyEncodingStrategy,
//                        userInfo: userInfo)
//    }
//    
//    // MARK: - Constructing a JSON Encoder
//    
//    /// Initializes `self` with default strategies.
//    public init() {}
//    
//    
//    //--------------------------------------------------------- END JSONEncoder
//    
//    //MARK: Encode
//    public func encode<T: Encodable>(_ value: T) throws -> Data {
//        let value:LCEncodedValue = try encodeValue(value)
//        let itemWriter = LCEncodedValue.Writer(options:OutputFormatting()) //no options yet.
//        let bytes = itemWriter.writeValue(value)
//        return Data(bytes)
//    }
//    
//    //This is all about making sure the individual items can be stringified.
//    func encodeValue<T: Encodable>(_ value: T) throws -> LCEncodedValue {
//        let encoder = LineEncoderImplementation(options: options, codingPath: [])
//        guard let topLevel = try encoder.wrapEncodable(value, additionalKey: nil) else {
//            //TODO: This in not my error.
//            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
//        }
//        
//        return topLevel
//    }
//    
//}
//
//
//
//
//fileprivate final class LineEncoderImplementation {
//    
//    init(options: LineMaker._Options, codingPath: [CodingKey]) {
//        self.options = options
//        self.codingPath = codingPath
//    }
//    
//    var options:LineMaker._Options
//    var WIP:LCWorkInProgress?
//    
//    
//    //needed for Encoder Implementation.
//    var codingPath: [CodingKey]
//    var userInfo: [CodingUserInfoKey : Any]  { [:] }
//    
//    //var singleValue: LCEncodedValue?
//    //var array: JSONFuture.RefArray?
//    //var object: JSONFuture.RefObject?
//    
//    var value: LCEncodedValue? {
//        if let WIP {
//            switch WIP {
//                
//            case .value(let value):
//                return value
//            case .encoder(let encoder):
//                return encoder.value
//            case .nestedObject(let object):
//                return .object(object.values)
//            }
//        } else {
//            return nil
//        }
//        
//        //        //        if let object = self.object {
//        //        //            return .object(object.values)
//        //        //        }
//        //        //        if let array = self.array {
//        //        //            return .array(array.values)
//        //        //        }
//        //        return self.singleValue
//    }
//    
//}
//
//extension LineEncoderImplementation: Encoder {
//    
//    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        //fatalError()
//        //return KeyedEncodingContainer(LineEncoderKEC(encoder: self, codingPath: codingPath))
//        if let WIP {
//            if case let .nestedObject(object) = WIP {
//                return KeyedEncodingContainer(LineEncoderKEC(codingPath: codingPath, object: object))
//            }
//        } else {
//            self.WIP = LCWorkInProgress.nestedObject(LCWorkInProgress.ObjectBox())
//            if case let .nestedObject(object) = WIP! {
//                return KeyedEncodingContainer(LineEncoderKEC(codingPath: codingPath, object: object))
//            }
//        }
//        fatalError()
//        
//        
//    }
//    
//    func unkeyedContainer() -> UnkeyedEncodingContainer {
//        fatalError()
//    }
//    
//    func singleValueContainer() -> SingleValueEncodingContainer {
//        return LineEncoderSVEC(encoderInstance: self, codingPath: codingPath)
//    }
//    
//    
//}
//
//extension LineEncoderImplementation: LCEncoder {
//    var encoderInstance: LineEncoderImplementation {
//        self
//    }
//    
//}
//
//
//private enum LCWorkInProgress {
//    case value(LCEncodedValue)
//    case encoder(LineEncoderImplementation)
//    //case nestedArray([LCWorkInProgress])
//    case nestedObject(ObjectBox)
//    
//    final class ObjectBox {
//        //private(set) var dict: [String: LCWorkInProgress] = [:]
//        
//        private(set) var dict: [String: LCWorkInProgress] = [:]
//        init() {
//            //self.dict.reserveCapacity(20)
//        }
//        
//        @inline(__always) func set(_ value: LCEncodedValue, for key: String) {
//            self.dict[key] = .value(value)
//        }
//        
//        var values: [String: LCEncodedValue] {
//            self.dict.mapValues { (future) -> LCEncodedValue in
//                switch future {
//                case .value(let value):
//                    return value
//                    //                case .nestedArray(let array):
//                    //                    return .array(array.values)
//                case .nestedObject(let object):
//                    return .object(object.values)
//                case .encoder(let encoder):
//                    return encoder.value ?? .object([:])
//                }
//            }
//        }
//        
//    }
//    
//}
//
//
//fileprivate struct LineEncoderKEC<Key: CodingKey>: KeyedEncodingContainerProtocol {
//    var codingPath: [CodingKey]
//    
//    //    var encoderInstance: LineEncoderImplementation
//    //            var options: LineMaker._Options {
//    //                encoderInstance.options
//    //            }
//    //            var codingPath: [CodingKey]
//    
//    var object:LCWorkInProgress.ObjectBox
//    
//    //            init(encoder: LineEncoderImplementation, codingPath: [CodingKey]) {
//    //                self.encoderInstance = encoder
//    //                if let WIP = encoderInstance.WIP {
//    //                    if case let .nestedObject(object) = WIP {
//    //                        self.object = object
//    //                    } else {
//    //                        fatalError()
//    //                    }
//    //                } else {
//    //                    self.object = LCWorkInProgress.ObjectBox()
//    //                }
//    //                self.codingPath = codingPath
//    //            }
//    //
//    //            // used for nested containers
//    //            init(encoder: LineEncoderImplementation, object: LCWorkInProgress.ObjectBox, codingPath: [CodingKey]) {
//    //                self.encoderInstance = encoder
//    //                self.object = object
//    //                self.codingPath = codingPath
//    //            }
//    
//    private func _converted(_ key: Key) -> CodingKey {
//        //        switch self.options.keyEncodingStrategy {
//        //        case .useDefaultKeys:
//        return key
//        //        case .convertToSnakeCase:
//        //            let newKeyString = JSONEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
//        //            return _JSONKey(stringValue: newKeyString, intValue: key.intValue)
//        //        case .custom(let converter):
//        //            return converter(codingPath + [key])
//        //        }
//    }
//    
//    
//    mutating func encodeNil(forKey key: Key) throws {
//        self.object.set(.null, for: self._converted(key).stringValue)
//    }
//    
//    mutating func encode(_ value: Bool, forKey key: Key) throws {
//        self.object.set(.bool(value), for: self._converted(key).stringValue)
//    }
//    
//    mutating func encode(_ value: String, forKey key: Key) throws {
//        self.object.set(.string(value), for: self._converted(key).stringValue)
//    }
//    
//    mutating func encode(_ value: Double, forKey key: Key) throws {
//        try encodeFloatingPoint(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Float, forKey key: Key) throws {
//        try encodeFloatingPoint(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Int, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Int8, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Int16, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Int32, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: Int64, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: UInt, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: UInt8, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: UInt16, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: UInt32, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode(_ value: UInt64, forKey key: Key) throws {
//        try encodeFixedWidthInteger(value, key: self._converted(key))
//    }
//    
//    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
//        fatalError()
//    }
//    
//    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
//        fatalError()
//    }
//    
//    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
//        fatalError()
//    }
//    
//    mutating func superEncoder() -> Encoder {
//        fatalError()
//    }
//    
//    mutating func superEncoder(forKey key: Key) -> Encoder {
//        fatalError()
//    }
//    
//    
//}
//
//extension LineEncoderKEC {
//    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F, key: CodingKey) throws {
//        
//        //TODO: Fix to use function.
//        var string = float.description
//        if string.hasSuffix(".0") {
//            string.removeLast(2)
//        }
//        self.object.set(.number(string), for: key.stringValue)
//    }
//    
//    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N, key: CodingKey) throws {
//        self.object.set(.number(value.description), for: key.stringValue)
//    }
//}
//
////MARK: SingleValueEncoder
//private struct LineEncoderSVEC: SingleValueEncodingContainer, LCEncoder {
//    
//    var encoderInstance: LineEncoderImplementation
//    var options: LineMaker._Options {
//        encoderInstance.options
//    }
//    var codingPath: [CodingKey]
//    
//    
//    //    func preconditionCanEncodeNewValue() {
//    //        precondition(self.impl.singleValue == nil, "Attempt to encode value through single value container when previously value already encoded.")
//    //    }
//    
//    
//    mutating func encodeNil() throws {
//        self.encoderInstance.WIP = .value(.null)
//    }
//    
//    mutating func encode(_ value: Bool) throws {
//        self.encoderInstance.WIP = .value(.bool(value))
//    }
//    
//    mutating func encode(_ value: String) throws {
//        self.encoderInstance.WIP = .value(.string(value))
//    }
//    
//    mutating func encode(_ value: Double) throws {
//        try encodeFloatingPoint(value)
//    }
//    
//    mutating func encode(_ value: Float) throws {
//        try encodeFloatingPoint(value)
//    }
//    
//    mutating func encode(_ value: Int) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: Int8) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: Int16) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: Int32) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: Int64) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: UInt) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: UInt8) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: UInt16) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: UInt32) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode(_ value: UInt64) throws {
//        try encodeFixedWidthInteger(value)
//    }
//    
//    mutating func encode<T>(_ value: T) throws where T : Encodable {
//        fatalError()
//    }
//    
//    
//}
//
//extension LineEncoderSVEC {
//    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
//        //self.preconditionCanEncodeNewValue()
//        self.encoderInstance.WIP = .value(.number(value.description))
//    }
//    
//    @inline(__always) private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
//        //self.preconditionCanEncodeNewValue()
//        let value = try self.wrapFloat(float, for: nil)
//        self.encoderInstance.WIP = .value(value)
//    }
//}
//
//
//
//
//fileprivate extension  LCEncoder {
//    //JSONEncoder.swift#L465
//    @inline(__always) func wrapFloat<F: FloatingPoint & CustomStringConvertible>(_ float: F, for additionalKey: CodingKey?) throws -> LCEncodedValue {
//        guard !float.isNaN, !float.isInfinite else {
//            if case .convertToString(let posInfString, let negInfString, let nanString) = self.options.nonConformingFloatEncodingStrategy {
//                switch float {
//                case F.infinity:
//                    return .string(posInfString)
//                case -F.infinity:
//                    return .string(negInfString)
//                default:
//                    // must be nan in this case
//                    return .string(nanString)
//                }
//            }
//            
//            var path = self.codingPath
//            if let additionalKey = additionalKey {
//                path.append(additionalKey)
//            }
//            
//            //TODO: Not my error.
//            throw EncodingError.invalidValue(float, .init(
//                codingPath: path,
//                debugDescription: "Unable to encode \(F.self).\(float)."
//            ))
//        }
//        
//        var string = float.description
//        if string.hasSuffix(".0") {
//            string.removeLast(2)
//        }
//        return .number(string)
//    }
//    
//    //changed "for" to additional key because for was ambiguous.
//    func wrapEncodable<E: Encodable>(_ encodable: E, additionalKey: CodingKey?) throws -> LCEncodedValue? {
//        switch encodable {
//        case let date as Date:
//            return try self.wrapDate(date, additionalKey: additionalKey)
//        case let data as Data:
//            return try self.wrapData(data, additionalKey: additionalKey)
//        case let url as URL:
//            return .string(url.absoluteString)
//        case let decimal as Decimal:
//            return .number(decimal.description)
//            //        case let object as _DictionaryIsEncodableMarker:
//            //            return try self.wrapObject(object as! [String: Encodable], for: additionalKey)
//        default:
//            let encoder = self.getEncoder(for: additionalKey)
//            try encodable.encode(to: encoder)
//            return encoder.value
//        }
//    }
//    
//    func wrapDate(_ date: Date, additionalKey: CodingKey?) throws -> LCEncodedValue {
//        switch self.options.dateEncodingStrategy {
//        case .deferredToDate:
//            let encoder = self.getEncoder(for: additionalKey)
//            try date.encode(to: encoder)
//            return encoder.value ?? .null
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
//            let encoder = self.getEncoder(for: additionalKey)
//            try closure(date, encoder)
//            // The closure didn't encode anything. Return the default keyed container.
//            return encoder.value ?? .object([:])
//        }
//    }
//    
//    func wrapData(_ data: Data, additionalKey: CodingKey?) throws -> LCEncodedValue {
//        switch self.options.dataEncodingStrategy {
//        case .deferredToData:
//            let encoder = self.getEncoder(for: additionalKey)
//            try data.encode(to: encoder)
//            return encoder.value ?? .null
//            
//        case .base64:
//            let base64 = data.base64EncodedString()
//            return .string(base64)
//            
//        case .custom(let closure):
//            let encoder = self.getEncoder(for: additionalKey)
//            try closure(data, encoder)
//            // The closure didn't encode anything. Return the default keyed container.
//            return encoder.value ?? .object([:])
//        }
//    }
//    
//    //    func wrapObject(_ object: [String: Encodable], for additionalKey: CodingKey?) throws -> EncodedValue {
//    //        var baseCodingPath = self.codingPath
//    //        if let additionalKey = additionalKey {
//    //            baseCodingPath.append(additionalKey)
//    //        }
//    //        var result = [String: EncodedValue]()
//    //        result.reserveCapacity(object.count)
//    //
//    //        try object.forEach { (key, value) in
//    //            var elemCodingPath = baseCodingPath
//    //            elemCodingPath.append(_PotentialNumericKey(stringValue: key, intValue: nil))
//    //            let encoder = Self(options: self.options, codingPath: elemCodingPath)
//    //
//    //            result[key] = try encoder.wrapUntyped(value)
//    //        }
//    //
//    //        return .object(result)
//    //    }
//    
//    func getEncoder(for additionalKey: CodingKey?) -> LineEncoderImplementation {
//        if let additionalKey = additionalKey {
//            var newCodingPath = self.codingPath
//            newCodingPath.append(additionalKey)
//            return LineEncoderImplementation(options: self.options, codingPath: newCodingPath)
//        }
//        
//        return self.encoderInstance
//    }
//}
//
//
//
//
//
////===----------------------------------------------------------------------===//
//// Shared ISO8601 Date Formatter
////===----------------------------------------------------------------------===//
//
////This package requires recent Swift. No conditional inclusion.
//internal var _iso8601Formatter: ISO8601DateFormatter = {
//    let formatter = ISO8601DateFormatter()
//    formatter.formatOptions = .withInternetDateTime
//    return formatter
//}()
//
//
//
////===----------------------------------------------------------------------===//
//// Shared Key Types
////===----------------------------------------------------------------------===//
////
////internal struct _PotentialNumericKey: CodingKey {
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
////    internal static let `super` = _PotentialNumericKey(stringValue: "super")!
////}
//
//
//
//extension LineMaker {
//    
//    struct Constants {
//        let nullText:[UInt8] = ._none
//    }
//    
//    var nullText:String {
//        String(bytes: self.options.constants.nullText, encoding: .utf8)!
//    }
//    
//    public struct OutputFormatting {
//        let constants:Constants = Constants()
//    }
//    
//    //--------------------------------------------------------- FROM JSONEncoder
//    public enum DateEncodingStrategy {
//        /// Defer to `Date` for choosing an encoding. This is the default strategy.
//        case deferredToDate
//        
//        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
//        case secondsSince1970
//        
//        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
//        case millisecondsSince1970
//        
//        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
//        case iso8601
//        
//        /// Encode the `Date` as a string formatted by the given formatter.
//        case formatted(DateFormatter)
//        
//        /// Encode the `Date` as a custom value encoded by the given closure.
//        ///
//        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
//        case custom((Date, Encoder) throws -> Void)
//    }
//    
//    /// The strategy to use for encoding `Data` values.
//    public enum DataEncodingStrategy {
//        /// Defer to `Data` for choosing an encoding.
//        case deferredToData
//        
//        /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
//        case base64
//        
//        /// Encode the `Data` as a custom value encoded by the given closure.
//        ///
//        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
//        case custom((Data, Encoder) throws -> Void)
//    }
//    
//    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
//    public enum NonConformingFloatEncodingStrategy {
//        /// Throw upon encountering non-conforming values. This is the default strategy.
//        case `throw`
//        
//        /// Encode the values using the given representation strings.
//        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
//    }
//    
//    /// The strategy to use for automatically changing the value of keys before encoding.
//    public enum KeyEncodingStrategy {
//        /// Use the keys specified by each type. This is the default strategy.
//        case useDefaultKeys
//        
//        /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to JSON payload.
//        ///
//        /// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
//        /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
//        ///
//        /// Converting from camel case to snake case:
//        /// 1. Splits words at the boundary of lower-case to upper-case
//        /// 2. Inserts `_` between words
//        /// 3. Lowercases the entire string
//        /// 4. Preserves starting and ending `_`.
//        ///
//        /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
//        ///
//        /// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
//        case convertToSnakeCase
//        
//        /// Provide a custom conversion to the key in the encoded JSON from the keys specified by the encoded types.
//        /// The full path to the current encoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before encoding.
//        /// If the result of the conversion is a duplicate key, then only one value will be present in the result.
//        case custom((_ codingPath: [CodingKey]) -> CodingKey)
//        
//        fileprivate static func _convertToSnakeCase(_ stringKey: String) -> String {
//            guard !stringKey.isEmpty else { return stringKey }
//            
//            var words: [Range<String.Index>] = []
//            // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
//            //
//            // myProperty -> my_property
//            // myURLProperty -> my_url_property
//            //
//            // We assume, per Swift naming conventions, that the first character of the key is lowercase.
//            var wordStart = stringKey.startIndex
//            var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex
//            
//            // Find next uppercase character
//            while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
//                let untilUpperCase = wordStart..<upperCaseRange.lowerBound
//                words.append(untilUpperCase)
//                
//                // Find next lowercase character
//                searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
//                guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
//                    // There are no more lower case letters. Just end here.
//                    wordStart = searchRange.lowerBound
//                    break
//                }
//                
//                // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
//                let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
//                if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
//                    // The next character after capital is a lower case character and therefore not a word boundary.
//                    // Continue searching for the next upper case for the boundary.
//                    wordStart = upperCaseRange.lowerBound
//                } else {
//                    // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
//                    let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
//                    words.append(upperCaseRange.lowerBound..<beforeLowerIndex)
//                    
//                    // Next word starts at the capital before the lowercase we just found
//                    wordStart = beforeLowerIndex
//                }
//                searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
//            }
//            words.append(wordStart..<searchRange.upperBound)
//            let result = words.map({ (range) in
//                return stringKey[range].lowercased()
//            }).joined(separator: "_")
//            return result
//        }
//    }
//    
//}
//
