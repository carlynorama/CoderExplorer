#  Coder Explorer

A place to finally learn about custom encoders and decoders.

## References

- https://www.whynotestflight.com/excuses/how-do-custom-encoders-work/

To work on this package I primarily used 3 resources, duplicating them line by line. No copy-paste. Xcode does a ton of providing missing code to be in compliance so that was less tedious than one may think. Some of the variable names will be changed from the example code. This is on purpose to make sure I don't start copy pasting and that I really do under stand what is connected to what.

- https://forums.swift.org/t/future-of-codable-and-json-coders-in-swift-6-hoping-for-a-rework/69542
- https://forums.swift.org/t/serialization-in-swift/46641

### StackOverflow 45169254

- https://stackoverflow.com/questions/45169254/custom-swift-encoder-decoder-for-the-strings-resource-format

Paulo Mattos provided an epic answer. 

- `StringsCoder/KeyValueEncoder.swift`
- Tests: `StringsCoderTests.swift`

- Strings

### objc.io

- https://talk.objc.io/episodes/S01E348-routing-with-codable-encoding
- https://github.com/objcio/S01E348-routing-with-codable-encoding/blob/main/Sources/CodableRouting/Encoding.swift

Very good video on making a router coder from an enum. 

- `objcCoder/RouterExample.swift`
- Tests:`RouterExampleTests.swift`

### JSONEncoder

#### 5.10
- https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/Proposals/0001-jsonencoder-key-strategy.md?plain=1
- https://github.com/apple/swift-corelibs-foundation/blob/release/5.10/Sources/Foundation/JSONEncoder.swift
- https://github.com/apple/swift-corelibs-foundation/blob/release/5.10/Tests/Foundation/Tests/TestJSONEncoder.swift
- https://github.com/apple/swift-corelibs-foundation/blob/release/5.10/Tests/Foundation/Tests/TestJSONSerialization.swift
- https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/JSONSerialization.swift#L629

- https://github.com/apple/swift/blob/48e65c6f8ca1a2a902df40c51173fc603b1611e2/stdlib/public/core/Codable.swift#L47

#### FoundationEssentials Version & Darwin/Foundation-swiftoverlay Version
- https://github.com/apple/swift-foundation/blob/main/Sources/FoundationEssentials/JSON/JSONEncoder.swift#L629
- https://github.com/apple/swift-foundation/blob/14815845f3531505311e9ae30e66055a46a4eb12/Sources/FoundationEssentials/CodableWithConfiguration.swift#L20
- https://github.com/apple/swift-corelibs-foundation/blob/7d40966ed21dc39846103a429f84f426be1f28da/Darwin/Foundation-swiftoverlay/JSONEncoder.swift#L448

#### Evolution Talk
- https://github.com/search?q=repo%3Aapple%2Fswift-evolution%20Encoder&type=code
- https://github.com/apple/swift-evolution/blob/main/proposals/0166-swift-archival-serialization.md
- https://github.com/apple/swift-evolution/blob/main/proposals/0167-swift-encoders.md
- https://github.com/apple/swift-evolution/blob/main/proposals/0239-codable-range.md
- https://github.com/apple/swift-evolution/blob/main/proposals/0295-codable-synthesis-for-enums-with-associated-values.md
-- https://github.com/apple/swift-evolution/blob/proposals/0320-codingkeyrepresentable.md

A beast, but very instructive. Started from [line 226](https://github.com/apple/swift-corelibs-foundation/blob/19e5eb0edebf67f69908f6ef0e9c0ad934848c82/Sources/Foundation/JSONEncoder.swift#L226) of the one in 5.10 and worked my way out until it worked. 

```
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        let value: JSONValue = try encodeAsJSONValue(value)
        let writer = JSONValue.Writer(options: self.outputFormatting)
        let bytes = writer.writeValue(value)

        return Data(bytes)
    }
```

That got ripped apart and turned into the first LineCoder. Then I found the one in FoundationEssentials and liked the way it had been reworked so tore everything out again. 

### Other Apple Encoders on GitHub

- https://github.com/search?q=org%3Aapple%20mutating%20func%20nestedContainer%3CNestedKey%3E(keyedBy%20keyType%3A%20NestedKey.Type%2C%20forKey%20key%3A%20Key)%20-%3E%20KeyedEncodingContainer%3CNestedKey%3E%20where%20NestedKey&type=code
- https://github.com/apple/swift-openapi-runtime/tree/release/0.2.x/Sources/OpenAPIRuntime/URICoder
- https://github.com/apple/swift-http-structured-headers/blob/main/Sources/StructuredFieldValues/
- https://github.com/apple/swift-http-structured-headers/

-  This one is extra interesting because its encoded straight to an output stream. No stored data at all.  https://github.com/apple/swift-package-manager/blob/a5f9b6cf7ceeea13b7db828b5eece2ca9e0df445/Sources/Commands/Utilities/PlainTextEncoder.swift



### More
- https://forums.swift.org/t/how-can-i-encode-a-struct-to-data-binary/68652
- String.propertyListFromStringsFileFormat() 
- Dictionary.descriptionInStringsFileFormat
- 2017 Mike Ash article: https://www.mikeash.com/pyblog/friday-qa-2017-07-28-a-binary-coder-for-swift.html
    - https://github.com/mikeash/BinaryCoder/blob/887cecd70c070d86f338065f59ed027c13952c83/BinaryEncoder.swift
- [I'd rather be using pkl](https://pkl-lang.org/swift/current/quickstart.html)
- https://github.com/CoreOffice/XMLCoder
- https://www.fivestars.blog/articles/codable-swift-dictionaries/
- https://www.swiftbysundell.com/articles/customizing-codable-types-in-swift/
- https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
- https://github.com/swiftcsv/SwiftCSV (does not use custom encoder)
- - https://github.com/apple/swift-protobuf/blob/main/Sources/SwiftProtobuf/JSONEncoder.swift (a distraction)
- https://github.com/apple/swift/blob/ec0f85635d433bcff87a6545ffdcd33d860c0d48/stdlib/public/core/EmbeddedStubs.swift#L195
