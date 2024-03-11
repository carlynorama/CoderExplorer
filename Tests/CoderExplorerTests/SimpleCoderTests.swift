//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/25/24.
//

import Foundation
import XCTest
@testable import CoderExplorer






final class CodeableStringExample:XCTestCase {
    let encoder = SimpleCoder()
    
    struct TestStruct:Codable {
        let number:Int
        let text:String
        let sub:TestSubStruct
    }
    
    struct TestSubStruct:Codable {
        let numeral:Int
        let string:String
    }
    
    
    
    func testExample() throws {
        let encoder = SimpleCoder()
        
        let sub = TestSubStruct(numeral: 34, string: "world")
        let testItem = TestStruct(number: 12, text: "hello", sub: sub)
        let expected = "number:12/sub.numeral:34/sub.string:world/text:hello"
        XCTAssertEqual(expected, try encoder.encode(testItem))
        
    }
    
    struct MoreItems:Codable {
        let myDouble:Double
        let myFloat:Float
        let myArray:[InsideStruct]
    }
    
    struct InsideStruct:Codable {
        let insideDouble:Double
        let insideFloat:Float
        //let insideArray:[TestSubStruct]
    }
    
    func testSingleLevelArrayExample() throws {
        let encoder = SimpleCoder()
        
        let subItem1 = InsideStruct(insideDouble: 0.234, insideFloat: 2144.421)
        let subItem2 = InsideStruct(insideDouble: 5.926, insideFloat: 0.00132)
        let subItem3 = InsideStruct(insideDouble: 312421.4124214, insideFloat: 421421.223)
        
        let testItem = MoreItems(myDouble: 8921.41421, myFloat: 1182.12, myArray: [subItem1, subItem2, subItem3])
        let expected =  "myArray.0.insideDouble:0.234/"  +
        "myArray.0.insideFloat:2144.4208984375/" +
        "myArray.1.insideDouble:5.926/" +
        "myArray.1.insideFloat:0.0013200000394135714/" +
        "myArray.2.insideDouble:312421.4124214/" +
        "myArray.2.insideFloat:421421.21875/" +
        "myDouble:8921.41421/" +
        "myFloat:1182.1199951171875"
        XCTAssertEqual(expected, try encoder.encode(testItem))
    }
    
    func testSingleValues() async throws {
        let encoder = SimpleCoder()
        
        let toEncodeInt = Int.random(in: Int.min...Int.max)
        let toEncodeText = "hello" //TODO: make random strings to test encodings in a different function.
        let toEncodeBool = Bool.random()
        let toEncodeDouble = Double.random(in: Double.leastNonzeroMagnitude...Double.greatestFiniteMagnitude)
        let toEncodeFloat = Float.random(in: Float.leastNonzeroMagnitude...Float.greatestFiniteMagnitude)
        let toEncodeInt32 = Int32.random(in: Int32.min...Int32.max)
        
        //let toEncodeOptionalInt:Int? = nil
        
        
        let encodedInt = try encoder.encode(toEncodeInt)
        let encodedText = try encoder.encode(toEncodeText)
        let encodedBool = try encoder.encode(toEncodeBool)
        
        let encodedDouble = try encoder.encode(toEncodeDouble)
        let encodedFloat = try encoder.encode(toEncodeFloat)
        let encodedInt32 = try encoder.encode(toEncodeInt32)
        
        //let encodedOptionalInt = try await encoder.encode(toEncodeOptionalInt)
        
        XCTAssertEqual(toEncodeInt.description, encodedInt)
        XCTAssertEqual(toEncodeText.description, encodedText)
        XCTAssertEqual(toEncodeBool.description, encodedBool)
        XCTAssertEqual(toEncodeDouble.description, encodedDouble)
        XCTAssertEqual(Double(toEncodeFloat).description, encodedFloat)
        XCTAssertEqual(toEncodeInt32.description, encodedInt32)
        //XCTAssertEqual(Data(encoder.encoder.nullValueOutput), encodedOptionalInt)
        
    }
    
    func testDate() throws {
        //let encoder = SimpleCoder()
        let date = Date()
        
        //------------------ SingleValue
        let dateString = date.ISO8601Format(.iso8601)
        let encodedDate = try encoder.encode(date)
        XCTAssertEqual(dateString, encodedDate)
        
        //--------- Keyed
        struct MiniWithDate:Encodable {
            let date:Date = Date()
        }
        
        let miniToTest = MiniWithDate()
        let structExpected = "date:\(miniToTest.date.ISO8601Format())"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let dateArray = [Date(), Date(), Date(), Date()]
        let arrayExpected = dateArray.enumerated().map ({ index, value in
            "\(index):\(value.ISO8601Format())"
        }).joined(separator: "/")
        let encodedArray = try encoder.encode(dateArray)
        XCTAssertEqual(arrayExpected, encodedArray)
    }
    
    func testURL() throws {
        //------------------ mostly HTTP Schema
        let http_url = URL(string: "http://www.example.com")!
        var components = URLComponents()
        components.scheme = "http"
        components.host = "www.example.com"
        components.queryItems = [URLQueryItem(name: "testQuery", value: "42")]
        let file_url = FileManager.default.homeDirectoryForCurrentUser
        
        let absoluteURL = URL(dataRepresentation: "http://www.example.com".data(using: .utf8)!, relativeTo: nil, isAbsolute: true)!
        
        let relativeURL = URL(fileURLWithPath: "hello.jpg", relativeTo: URL(string:"http://www.example.com"))
        
        //------------------ SingleValue
        let httpUrlString = http_url.relativeString //.absoluteString
        let httpEncodedURL = try encoder.encode(http_url)
        XCTAssertEqual(httpUrlString, httpEncodedURL)
        
        //--------- Keyed
        struct MiniWithHttpURL:Encodable {
            let url:URL = URL(string: "http://www.example.com")!
        }
        
        let httpMiniToTest = MiniWithHttpURL()
        let httpStructExpected = "url:\(httpMiniToTest.url.absoluteString)"
        let httpEncodedStruct = try encoder.encode(httpMiniToTest)
        XCTAssertEqual(httpStructExpected, httpEncodedStruct)
        
        //--------- Unkeyed
        let urlArray = [http_url, components.url!, absoluteURL, relativeURL, file_url]
        let httpArrayExpected = urlArray.enumerated().map ({ index, value in
            "\(index):\(value.absoluteString)"
        }).joined(separator: "/")
        let encodedURLArray = try encoder.encode(urlArray)
        XCTAssertEqual(httpArrayExpected, encodedURLArray)
    }
    
    func testData() throws {
        let encoder = SimpleCoder()
        
        //------------------ SingleValue
        let data = Data([10, 15, 20])
        let dataString = data.base64EncodedString()
        let encodedData = try encoder.encode(data)
        XCTAssertEqual(dataString, encodedData)
        
        //--------- Keyed
        struct MiniWithData:Encodable {
            let myData:Data = Data([10, 15, 20, 127, 0])
        }
        
        let miniToTest = MiniWithData()
        let structExpected = "myData:Cg8UfwA="
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let dataArray = [data, data, data, data]
        let structArray = [miniToTest, miniToTest]
        let arrayExpected = dataArray.enumerated().map ({ index, value in
            "\(index):\(value.base64EncodedString())"
        }).joined(separator: "/")
        let encodedArray = try encoder.encode(dataArray)
        XCTAssertEqual(arrayExpected, encodedArray)
        
        let structArrayExpected = "0.myData:Cg8UfwA=/1.myData:Cg8UfwA="
        let encodedStructArray = try encoder.encode(structArray)
        XCTAssertEqual(structArrayExpected, encodedStructArray)
        
    }
    
    func testBasicNil() throws {
        let encoder = SimpleCoder()
        
        //------------------ SingleValue
        let optionalValue:Int? = nil
        let optionalString = "NULL"
        let encodedOptional = try encoder.encode(optionalValue)
        XCTAssertEqual(optionalString, encodedOptional)
        
        //--------- Keyed
        struct MiniStruct:Encodable {
            let noneInt:Int? = nil
            let someInt:Int? = 12
        }
        
        let miniToTest = MiniStruct()
        let structExpected = "someInt:12"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        
        func renderArray(_ array:[Int?], prepend:String = "") -> String {
            array.enumerated().map ({ index, value in
                let valueString = value != nil ? "\(value!)" : "NULL"
                return "\(prepend)\(index):\(valueString)"
            }).joined(separator: "/")
        }
        
        //--------- Unkeyed
        
        let array = [10, nil, 20, nil, 0]
        let arrayExpected = renderArray(array)
        let encodedArray = try encoder.encode(array)
        XCTAssertEqual(arrayExpected, encodedArray)
        
        let subArray:[[Int?]?] = [array, nil, array]
        let subArrayExpected = subArray.enumerated().map({
            if let notNil = $1 {
                return renderArray(notNil, prepend: "\($0).")
            } else {
                return "\($0):NULL"
            }
            }).joined(separator: "/")
        let encodedSubArray = try encoder.encode(subArray)
        XCTAssertEqual(subArrayExpected, encodedSubArray)
        
        struct MiniArrayStruct:Encodable {
            let myIntArray:[Int?] = [10, nil, 20, nil, 0]
        }
        let miniArratStructToTest = MiniArrayStruct()
        let structArray = [miniArratStructToTest, miniArratStructToTest]
        let structArrayExpected = structArray.enumerated().map ({ index, value in
            renderArray(value.myIntArray, prepend: "\(index).myIntArray.")
        }).joined(separator: "/")
        let encodedStructArray = try encoder.encode(structArray)
        XCTAssertEqual(structArrayExpected, encodedStructArray)
        
    }
    
    //TODO: Make this work better.
   
    
    func testRawRepresentableEnum() throws {
        let encoder = SimpleCoder()
        
        //Runs as String?
        enum Greeting:String,Codable {
            case hello, howdy, hola, hi, hiya
        }
        
        //------------------ SingleValue
        let enumValue:Greeting = .hiya
        let expectedEnumString = "hiya"
        let encodedEnum = try encoder.encode(enumValue)
        XCTAssertEqual(expectedEnumString, encodedEnum)
        
        //--------- Keyed
        struct MiniWithEnum:Encodable {
            let otherValue:Double = 42
            let myGreeting:Greeting = .hello
            let otherStringValue = "world"
        }
        
        let miniToTest = MiniWithEnum()
        let structExpected = "myGreeting:\(miniToTest.myGreeting)/otherStringValue:world/otherValue:42.0"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let enumArray:[Greeting] = [.hello, .howdy, .hiya, .hola]
        let arrayExpected = enumArray.enumerated().map ({ index, value in
            "\(index):\(value)"
        }).joined(separator: "/")
        let encodedArray = try encoder.encode(enumArray)
        XCTAssertEqual(arrayExpected, encodedArray)
    }
    
    func testCustomizedEnum() throws {
        
        enum FruitChoice:Encodable {
            case strawberry, pineapple, dragon, kiwi, kumquat
            
            //                public func encode(to encoder: Encoder) throws {
            //                    var container = encoder.singleValueContainer()
            //                    try container.encode("\(self)")
            //                }
            //
            //                public func encode(to encoder: Encoder) throws {
            //                    let asObject = ["FruitChoice":"\(self)"]
            //                    var container = encoder.singleValueContainer()
            //                    try container.encode(asObject)
            //                }
            
            
            enum CodingKeys:CodingKey {
                case fruitChoice
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: Self.CodingKeys.self)
                try container.encode("\(self)", forKey: .fruitChoice)
            }
            
        }
        
        //------------------ SingleValue
        let enumFruitValue:FruitChoice = .strawberry//(strawberry: "Everbearing")
        let expectedEnumFruitString = "fruitChoice:strawberry"
        let encodedFruitEnum = try encoder.encode(enumFruitValue)
        XCTAssertEqual(expectedEnumFruitString, encodedFruitEnum)
        
        //--------- Keyed
        struct MiniWithEnum:Encodable {
            let otherValue:Double = 42
            let myFruit:FruitChoice = .pineapple
            let otherStringValue = "world"
        }
        
        let miniToTest = MiniWithEnum()
        let structExpected = "myFruit.fruitChoice:\(miniToTest.myFruit)/otherStringValue:world/otherValue:42.0"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let enumArray:[FruitChoice] = [.strawberry, .dragon, .kiwi, .kumquat]
        
        let arrayExpected = enumArray.enumerated().map ({ index, value in
            "\(index).fruitChoice:\(value)"
        }).joined(separator: "/")
        let encodedArray = try encoder.encode(enumArray)
        XCTAssertEqual(arrayExpected, encodedArray)
        
    }
    
    func testAssociatedValueEnum() throws {
        //Essentially the same as below, but requires labels
        //        enum FruitChoice:Encodable {
        //            case strawberry(name:String, cropCount:Int), pineapple(yearsToFruit:Double), kumquat(dateAcquired:Date)
        //        }
        
        enum FruitChoice:Encodable {
            case strawberry(String, Int), pineapple(Double), kumquat(Date)
            
            enum CodingKeys:CodingKey {
                case strawberry
                case pineapple
                case kumquat
            }
            
            enum StrawberryCodingKeys: CodingKey {
                case name
                case cropCount
            }
            
            enum PineappleCodingKeys: CodingKey {
                case yearsToFruit
            }
            
            enum KumquatCodingKeys: CodingKey {
                case dateAquired
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                    
                case .strawberry(let string, let int):
                    var nestedContainer = container.nestedContainer(keyedBy: StrawberryCodingKeys.self, forKey: .strawberry)
                    try nestedContainer.encode(string, forKey: .name)
                    try nestedContainer.encode(int, forKey: .cropCount)
                case .pineapple(let double):
                    var nestedContainer = container.nestedContainer(keyedBy: PineappleCodingKeys.self, forKey: .pineapple)
                    try nestedContainer.encode(double, forKey: .yearsToFruit)
                case .kumquat(let date):
                    var nestedContainer = container.nestedContainer(keyedBy: KumquatCodingKeys.self, forKey: .kumquat)
                    try nestedContainer.encode(date, forKey: .dateAquired)
                }
            }
        }
        
        //------------------ SingleValue
        let enumFruitValue:FruitChoice = .strawberry("Everbearing", 6)
        let expectedEnumFruitString = "strawberry.cropCount:6/strawberry.name:Everbearing"
        let encodedFruitEnum = try encoder.encode(enumFruitValue)
        XCTAssertEqual(expectedEnumFruitString, encodedFruitEnum)
        
        //--------- Keyed
        struct MiniWithEnum:Encodable {
            let otherValue:Double = 42
            let myFruit:FruitChoice = .pineapple(3.12)
            let otherStringValue = "world"
        }
        
        let miniToTest = MiniWithEnum()
        let structExpected = "myFruit.pineapple.yearsToFruit:3.12/otherStringValue:world/otherValue:42.0"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let enumArray:[FruitChoice] = [.strawberry("Everbearing", 6), .pineapple(1.23343), .kumquat(try Date("2024-03-10T21:36:24Z", strategy: .iso8601))]
        
        //        let arrayExpected = enumArray.enumerated().map ({ index, value in
        //            "\(index).fruitChoice:\(value)"
        //        }).joined(separator: "/")
        let arrayExpected = "0.strawberry.cropCount:6/0.strawberry.name:Everbearing/1.pineapple.yearsToFruit:1.23343/2.kumquat.dateAquired:2024-03-10T21:36:24Z"
        let encodedArray = try encoder.encode(enumArray)
        XCTAssertEqual(arrayExpected, encodedArray)
        
    }
    
//    func testAssociatedNil() throws {
//        enum SmallTalk:Codable {
//            case hello(String?)
//            case weather(String?)
//            case pets(String?)
//            case health(String?)
//            indirect case conversation([SmallTalk])
//        }
//        
//        //------------------ SingleValue
//        let enumValue:SmallTalk = .hello(nil)
//        let expectedEnumString = ""
//        let encodedEnum = try encoder.encode(enumValue)
//        XCTAssertEqual(expectedEnumString, encodedEnum)
//        
//        //--------- Keyed
//        struct MiniWithEnum:Encodable {
//            let otherValue:Double = 42
//            let noSmallTalk:SmallTalk = .hello(nil)
//            let someSmallTalk:SmallTalk = .hello("Hey!")
//            let otherStringValue = "world"
//        }
//        
//        let miniToTest = MiniWithEnum()
//        let structExpected = "otherStringValue:world/otherValue:42.0"
//        let encodedStruct = try encoder.encode(miniToTest)
//        XCTAssertEqual(structExpected, encodedStruct)
//        
//        func renderArray(_ array:[SmallTalk?], prepend:String = "") -> String {
//            array.enumerated().map ({ index, value in
//                let valueString = value != nil ? "\(value!)" : "NULL"
//                return "\(prepend)\(index):\(valueString)"
//            }).joined(separator: "/")
//        }
//        
//        //--------- Unkeyed
//        let enumArray:[SmallTalk?] = [.hello("Hi there"), .pets("Got any pets?"), .health(nil), nil, .weather("Nice day out today.")]
//        let arrayExpected = renderArray(enumArray)
//        let encodedArray = try encoder.encode(enumArray)
//        XCTAssertEqual(arrayExpected, encodedArray)
//        
//        //--------- really Unkeyed
//        let stArray:[SmallTalk] = [.hello("Hi there"), .pets("Got any pets?"), .health(nil), .weather("Nice day out today.")]
//        let indirectArray:SmallTalk = .conversation(stArray)
//        let indirectArrayExpected = ""
//        let encodedIndirectArray = try encoder.encode(indirectArray)
//        XCTAssertEqual(indirectArrayExpected, encodedIndirectArray)
//    }
//    
    
    func testBasicDictionary() throws {
        
        let dictionaryA:Dictionary<String,UInt32> = [
            "one":1,
            "two":2,
            "three": 3
        ]
        
        let dictionaryB = [
            1:"one",
            2:"two",
            3:"three"
        ]
        
        struct MiniToEmbed:Encodable {
            let otherValue:Double
            let otherStringValue:String
        }
        
        let dictionaryC = [
            "A":MiniToEmbed(otherValue: 56, otherStringValue: "hello"),
            "B":MiniToEmbed(otherValue:12, otherStringValue:"world"),
        ]
        
        //------------------ SingleValue
        let expectedA = "one:1/three:3/two:2"
        let expectedB = "1:one/2:two/3:three"
        let expectedC = "A.otherStringValue:hello/A.otherValue:56.0/B.otherStringValue:world/B.otherValue:12.0"
        let encodedA = try encoder.encode(dictionaryA)
        let encodedB = try encoder.encode(dictionaryB)
        let encodedC = try encoder.encode(dictionaryC)
        XCTAssertEqual(expectedA, encodedA)
        XCTAssertEqual(expectedB, encodedB)
        XCTAssertEqual(expectedC, encodedC)
        
        //--------- Keyed
        struct MiniWithDict:Encodable {
            let first:Dictionary<String,UInt32>
            let second:Dictionary<Int,String>
            let third:Dictionary<String, MiniToEmbed>
        }
        
        let miniToTest = MiniWithDict(first: dictionaryA, second: dictionaryB, third: dictionaryC)
        let structExpected = "first.one:1/first.three:3/first.two:2/second.1:one/second.2:two/second.3:three/third.A.otherStringValue:hello/third.A.otherValue:56.0/third.B.otherStringValue:world/third.B.otherValue:12.0"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let dictArray = [dictionaryA, dictionaryA]
        
        let arrayExpected = "0.one:1/0.three:3/0.two:2/1.one:1/1.three:3/1.two:2"
        let encodedArray = try encoder.encode(dictArray)
        XCTAssertEqual(arrayExpected, encodedArray)
        
        let structArray = [dictionaryC, dictionaryC]
        let structArrayExpected = "0.A.otherStringValue:hello/0.A.otherValue:56.0/0.B.otherStringValue:world/0.B.otherValue:12.0/1.A.otherStringValue:hello/1.A.otherValue:56.0/1.B.otherStringValue:world/1.B.otherValue:12.0"
        let encodedStructArray = try encoder.encode(structArray)
        XCTAssertEqual(structArrayExpected, encodedStructArray)
    }
    
    
    //EXAMPLE. Can only pass intermittently until can do a round trip.
//    func testUnofficialKeyDictionary() throws {
//        struct MyKey:Hashable, Codable, Comparable {
//            static func < (lhs: MyKey, rhs: MyKey) -> Bool {
//                lhs.id < rhs.id
//            }
//            
//            var id:UInt8
//        }
//        
//        let dictionaryA:Dictionary<MyKey, Int> = [
//            MyKey(id: 127):1,
//            MyKey(id: 126):2,
//            MyKey(id: 125):3
//        ]
//        
//        let expectedA = "0.id:127/" +
//                        "1:1/" +
//                        "2.id:126/" +
//                        "3:2/" +
//                        "4.id:125/" +
//                        "5:3"
//        let encodedA = try encoder.encode(dictionaryA)
//        //.sorted(by: { $0.key < $1.key }) not Encodable
//        XCTAssert(encodedA.contains(".id:126/"))
//        XCTAssert(encodedA.contains(":2/"))
//    }
    
    
    func testSomeEncodableKeyDictionary() throws {
        
        enum FruitKey:String, Codable, CodingKeyRepresentable {
            case strawberry, banana, kiwi
        }

        let dictionaryA:Dictionary<FruitKey,UInt32> = [
            .strawberry:1,
            .banana:2,
            .kiwi: 3
        ]
        
        struct FlowerCodingKey: CodingKey {
            let stringValue: String
            var intValue: Int?
            
            init?(stringValue: String) {  self.stringValue = stringValue  }
            init?(intValue: Int) {
                self.stringValue = String(intValue)
                self.intValue = intValue
            }
            init(_ flower:Flower) {
                self.stringValue = flower.name
            }
        }
        
        struct Flower:Hashable,Codable, CodingKeyRepresentable {
            let name:String
            init(_ name:String) {
                self.name = name
            }
            
            var codingKey: any CodingKey {
                FlowerCodingKey.init(self)
            }
            
            init?<T>(codingKey: T) where T : CodingKey {
                self.name = codingKey.stringValue
            }
        }

        let dictionaryB:Dictionary<Flower,Int> = [
            Flower("anemone"):7,
            Flower("freesia"):6,
            Flower("periwinkle"):5
        ]

        //------------------ SingleValue
        let expectedA = "banana:2/kiwi:3/strawberry:1"
        let expectedB = "anemone:7/freesia:6/periwinkle:5"
        let encodedA = try encoder.encode(dictionaryA)
        let encodedB = try encoder.encode(dictionaryB)
        XCTAssertEqual(expectedA, encodedA)
        XCTAssertEqual(expectedB, encodedB)

        //--------- Keyed
        struct MiniWithDict:Encodable {
            let first:Dictionary<FruitKey,UInt32>
            let second:Dictionary<Flower,Int>
        }

        let miniToTest = MiniWithDict(first: dictionaryA, second: dictionaryB)
        let structExpected = "first.banana:2/first.kiwi:3/first.strawberry:1/second.anemone:7/second.freesia:6/second.periwinkle:5"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)

        //--------- Unkeyed
        let dictArray = [dictionaryB, dictionaryB]

        let arrayExpected = "0.anemone:7/0.freesia:6/0.periwinkle:5/1.anemone:7/1.freesia:6/1.periwinkle:5"
        let encodedArray = try encoder.encode(dictArray)
        XCTAssertEqual(arrayExpected, encodedArray)

    }



    
    //MARK: Super
    func testCustomSuper() throws {
        class MyCodable:Encodable {
            var variable:String = "hello"
            
            public enum CodingKeys: CodingKey {
                case variable
            }
        }
        
        final class MySubCodable : MyCodable {
            init(_ variable:String) {
                super.init()
                self.variable = variable
            }
            public override func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try super.encode(to: container.superEncoder())
            }
        }
        
        //--------- SingleValue
//        let myThing = MySubCodable("world")
//        let expectedThing = "variable:world"
//        let encodedThing = try encoder.encode(myThing)
//        XCTAssertEqual(expectedThing, encodedThing)
//        
        //--------- Keyed
        struct MiniStruct:Encodable {
            let subC:MySubCodable
        }
        
        var miniToTest = MiniStruct(
            subC: MySubCodable("nothing to see")//,
            //text: myFancyText
        )
        
        let structExpected = "subC.variable:nothing to see"
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let enumArray:[MySubCodable] = [MySubCodable("La"), MySubCodable("Dee"), MySubCodable("Dah")]
        
        let arrayExpected = enumArray.enumerated().map ({ index, value in
            "\(index).variable:\(value.variable)"
        }).joined(separator: "/")
        let encodedArray = try encoder.encode(enumArray)
        XCTAssertEqual(arrayExpected, encodedArray)
        
    }
    
    func testAttribString() throws {
        var myFancyText = AttributedString("This will be a string with attributes.")
        myFancyText.paragraphStyle = .default
//                myFancyText.backgroundColor = .yellow
//                let range = myFancyText.range(of: "string")
//                if let range {
//                    myFancyText[range].foregroundColor = .green
//                }
                let expectedText = "0:This will be a string with attributes./1.NSParagraphStyle:YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGjCwwVVSRudWxs1A0ODxAREhMUWk5TVGFiU3RvcHNbTlNBbGlnbm1lbnRfEB9OU0FsbG93c1RpZ2h0ZW5pbmdGb3JUcnVuY2F0aW9uViRjbGFzc4AAEAQQAYAC0hYXGBlaJGNsYXNzbmFtZVgkY2xhc3Nlc18QEE5TUGFyYWdyYXBoU3R5bGWiGBpYTlNPYmplY3QIERokKTI3SUxRU1ddZnF9n6aoqqyus77H2t0AAAAAAAABAQAAAAAAAAAbAAAAAAAAAAAAAAAAAAAA5g=="
                let encodedText = try encoder.encode(myFancyText)
        print(encodedText)
                XCTAssertEqual(expectedText, encodedText)
        
        //--------- Keyed
        struct MiniStruct:Encodable {
            let text:AttributedString
        }
        
        var miniToTest = MiniStruct(text: myFancyText)
        
        let structExpected = "text.0:This will be a string with attributes./text.1.NSParagraphStyle:YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGjCwwVVSRudWxs1A0ODxAREhMUWk5TVGFiU3RvcHNbTlNBbGlnbm1lbnRfEB9OU0FsbG93c1RpZ2h0ZW5pbmdGb3JUcnVuY2F0aW9uViRjbGFzc4AAEAQQAYAC0hYXGBlaJGNsYXNzbmFtZVgkY2xhc3Nlc18QEE5TUGFyYWdyYXBoU3R5bGWiGBpYTlNPYmplY3QIERokKTI3SUxRU1ddZnF9n6aoqqyus77H2t0AAAAAAAABAQAAAAAAAAAbAAAAAAAAAAAAAAAAAAAA5g=="
        let encodedStruct = try encoder.encode(miniToTest)
        XCTAssertEqual(structExpected, encodedStruct)
        
        //--------- Unkeyed
        let structArray:[MiniStruct] = [MiniStruct(text: myFancyText), MiniStruct(text: myFancyText), MiniStruct(text: myFancyText)]
        
        let arrayExpected = "0.text.0:This will be a string with attributes./0.text.1.NSParagraphStyle:YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGjCwwVVSRudWxs1A0ODxAREhMUWk5TVGFiU3RvcHNbTlNBbGlnbm1lbnRfEB9OU0FsbG93c1RpZ2h0ZW5pbmdGb3JUcnVuY2F0aW9uViRjbGFzc4AAEAQQAYAC0hYXGBlaJGNsYXNzbmFtZVgkY2xhc3Nlc18QEE5TUGFyYWdyYXBoU3R5bGWiGBpYTlNPYmplY3QIERokKTI3SUxRU1ddZnF9n6aoqqyus77H2t0AAAAAAAABAQAAAAAAAAAbAAAAAAAAAAAAAAAAAAAA5g==/1.text.0:This will be a string with attributes./1.text.1.NSParagraphStyle:YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGjCwwVVSRudWxs1A0ODxAREhMUWk5TVGFiU3RvcHNbTlNBbGlnbm1lbnRfEB9OU0FsbG93c1RpZ2h0ZW5pbmdGb3JUcnVuY2F0aW9uViRjbGFzc4AAEAQQAYAC0hYXGBlaJGNsYXNzbmFtZVgkY2xhc3Nlc18QEE5TUGFyYWdyYXBoU3R5bGWiGBpYTlNPYmplY3QIERokKTI3SUxRU1ddZnF9n6aoqqyus77H2t0AAAAAAAABAQAAAAAAAAAbAAAAAAAAAAAAAAAAAAAA5g==/2.text.0:This will be a string with attributes./2.text.1.NSParagraphStyle:YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGjCwwVVSRudWxs1A0ODxAREhMUWk5TVGFiU3RvcHNbTlNBbGlnbm1lbnRfEB9OU0FsbG93c1RpZ2h0ZW5pbmdGb3JUcnVuY2F0aW9uViRjbGFzc4AAEAQQAYAC0hYXGBlaJGNsYXNzbmFtZVgkY2xhc3Nlc18QEE5TUGFyYWdyYXBoU3R5bGWiGBpYTlNPYmplY3QIERokKTI3SUxRU1ddZnF9n6aoqqyus77H2t0AAAAAAAABAQAAAAAAAAAbAAAAAAAAAAAAAAAAAAAA5g=="
        
        let encodedArray = try encoder.encode(structArray)
        XCTAssertEqual(arrayExpected, encodedArray)
    }
}






