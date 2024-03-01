//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/27/24.
//

import Foundation
import XCTest
@testable import CoderExplorer


final class LineCoderTests: XCTestCase {
    struct TestStruct:Codable {
        let int:Int
        let text:String
        let bool:Bool
        let optionalInt:Int?
        let double:Double
        let float:Float
        let int32:Int32
        //let sub:TestSubStruct
        init(int: Int, text: String, bool: Bool, optionalInt: Int?, double: Double, float: Float, int32: Int32) {
            self.int = int
            self.text = text
            self.bool = bool
            self.optionalInt = optionalInt
            self.double = double
            self.float = float
            self.int32 = int32
        }
        
        init() {
            self.int = 12
            self.text = "hello"
            self.bool = true
            self.optionalInt = nil
            self.double = 642.4341
            self.float = 62.12
            self.int32 = 3000
        }
        
    }
    
    struct NestedStruct:Codable {
        let int:Int
        let text:String
        let bool:Bool
        let optionalInt:Int?
        let double:Double
        let float:Float
        let int32:Int32
        let sub:TestSubStruct
        //let sub:TestSubStruct
        init(int: Int, text: String, bool: Bool, optionalInt: Int?, double: Double, float: Float, int32: Int32, sub: TestSubStruct) {
            self.int = int
            self.text = text
            self.bool = bool
            self.optionalInt = optionalInt
            self.double = double
            self.float = float
            self.int32 = int32
            self.sub = sub
        }
        
        init() {
            self.int = 12
            self.text = "hello"
            self.bool = true
            self.optionalInt = nil
            self.double = 642.4341
            self.float = 62.12
            self.int32 = 3000
            self.sub = TestSubStruct(moarText: "This is some text", numeral: 76, string: "world", numeroDuo: 257, intOla: 34324531)
        }
        
    }
    
    struct WeirdItems:Codable {
        let date:Date
        let URL: URL
        let dictIS: Dictionary<Int,String>
        let greeting:Greetings
        
        enum Greetings:Codable {
            case hello, howdy, hola, hi, hiya
        }
        
        init(date: Date, URL: URL, dictIS: Dictionary<Int, String>, getting: Greetings) {
            self.date = date
            self.URL = URL
            self.dictIS = dictIS
            self.greeting = getting
        }
        
        init() {
            self.date = .now
            self.URL = FileManager.default.homeDirectoryForCurrentUser
            self.dictIS = [12:"twelve", 11:"eleven"]
            self.greeting = .hola
        }
    }
    
    
    struct TestSubStruct:Codable {
        let moarText:String
        let numeral:Int
        let string:String
        let numeroDuo: Int16
        let intOla:Int
    }
    
    struct MiniStruct:Codable {
        let numeral:Int
        let string:String
        var array = [54,45,67,89]
        
        init() {
            self.numeral = 4314124
            self.string = "world"
        }
    }
    
    
    
    func testSingleValues() async throws {
        let LC = LineCoder()
        
        let toEncodeInt = Int.random(in: Int.min...Int.max)
        let toEncodeText = "hello" //TODO: make random strings to test encodings in a different function.
        let toEncodeBool = Bool.random()
        let toEncodeDouble = Double.random(in: Double.leastNonzeroMagnitude...Double.greatestFiniteMagnitude)
        let toEncodeFloat = Float.random(in: Float.leastNonzeroMagnitude...Float.greatestFiniteMagnitude)
        let toEncodeInt32 = Int32.random(in: Int32.min...Int32.max)
        
        let toEncodeOptionalInt:Int? = nil
        
        
        let encodedInt = try await LC.encode(toEncodeInt).utf8String
        let encodedText = try await LC.encode(toEncodeText).utf8String
        let encodedBool = try await LC.encode(toEncodeBool).utf8String
        
        let encodedDouble = try await LC.encode(toEncodeDouble).utf8String
        let encodedFloat = try await LC.encode(toEncodeFloat).utf8String
        let encodedInt32 = try await LC.encode(toEncodeInt32).utf8String
        
        let encodedOptionalInt = try await LC.encode(toEncodeOptionalInt)
        
        XCTAssertEqual(toEncodeInt.description, encodedInt)
        XCTAssertEqual(toEncodeText.description, encodedText)
        XCTAssertEqual(toEncodeBool.description, encodedBool)
        XCTAssertEqual(toEncodeDouble.description, encodedDouble)
        XCTAssertEqual(toEncodeFloat.description, encodedFloat)
        XCTAssertEqual(toEncodeInt32.description, encodedInt32)
        XCTAssertEqual(Data(LC.encoder.nullValueOutput), encodedOptionalInt)
        
        let url = FileManager.default.homeDirectoryForCurrentUser
        let date = Date()
        let number = Decimal(78.326)
        let data = Data([10, 15, 20])
        
        let dateString = date.ISO8601Format(.iso8601)
        let urlString = url.absoluteString
        let decimalString = number.description
        let dataString = data.base64EncodedString()
        
        let encodedDate = try await LC.encode(date).utf8String
        let encodedURL = try await LC.encode(url).utf8String
        let encodedDecimal = try await LC.encode(number).utf8String
        let encodedData = try await LC.encode(data).utf8String
        
        XCTAssertEqual(dateString, encodedDate)
        XCTAssertEqual(urlString, encodedURL)
        XCTAssertEqual(decimalString, encodedDecimal)
        XCTAssertEqual(dataString, encodedData)
        
    }
    
    func testSimpleObject() async throws {
        //        let sub = TestSubStruct(numeral: 34, string: "world")
        let testItem = TestStruct()
        let LC = LineCoder()
        let encoded = try await LC.encode(testItem).utf8String
        XCTAssertEqual("[bool:true,double:642.4341,float:62.12,int:12,int32:3000,text:hello]", encoded)
    }
    
    func testNestedObject() async throws {
        let testItem = NestedStruct()
        let LC = LineCoder()
        
        LC.encoder.showKeysForContainers = true //the default
        let encoded = try await LC.encode(testItem).utf8String
        let keyedExpected = "[bool:true,double:642.4341,float:62.12,int:12,int32:3000,sub:[sub.intOla:34324531,sub.moarText:This is some text,sub.numeral:76,sub.numeroDuo:257,sub.string:world],text:hello]"
        
        XCTAssertEqual(keyedExpected, encoded)
        
        LC.encoder.showKeysForContainers = false
        let encodedNoKeys = try await LC.encode(testItem).utf8String
        let unkeyedExpected = "[bool:true,double:642.4341,float:62.12,int:12,int32:3000,[sub.intOla:34324531,sub.moarText:This is some text,sub.numeral:76,sub.numeroDuo:257,sub.string:world],text:hello]"
        
        XCTAssertEqual(unkeyedExpected, encodedNoKeys)
    }
    
    func testBasicArrays() async throws {
        let LC = LineCoder()
        //won't see keys in this test because single values never show keys.
        //LineEncoderIKUEC has alternate implementations that can force them.
        //there isn't an option to toggle that because "force keys for everything"
        //might be something to do more generically.
        LC.encoder.indexKeyedArrays = true
        let array = Array(repeating: "howdy", count: 5)
        let encoded = try await LC.encode(array).utf8String
        let test = """
howdy
howdy
howdy
howdy
howdy
"""
        XCTAssertEqual("howdy\nhowdy\nhowdy\nhowdy\nhowdy", encoded)
        XCTAssertEqual(test, encoded)
        
        
        let intArray = Array(repeating: 34, count: 5)
        let encodedIntArray = try await LC.encode(intArray).utf8String
        XCTAssertEqual("34\n34\n34\n34\n34", encodedIntArray)
        
        //encoder.encoder.indexKeyedArrays = true
        
    }
        
    func testArrayInStruct() async throws {
        let LC = LineCoder()
        let miniStructArray = Array(repeating: MiniStruct(), count: 5)
        
        //encoder.encoder.showKeysForContainers = false
        LC.encoder.indexKeyedArrays = true
        let encodedMiniStructIK = try await LC.encode(miniStructArray).utf8String
        let indexKeyedOutput = "[0.array:[54,45,67,89],0.numeral:4314124,0.string:world]\n[1.array:[54,45,67,89],1.numeral:4314124,1.string:world]\n[2.array:[54,45,67,89],2.numeral:4314124,2.string:world]\n[3.array:[54,45,67,89],3.numeral:4314124,3.string:world]\n[4.array:[54,45,67,89],4.numeral:4314124,4.string:world]"
        XCTAssertEqual(indexKeyedOutput, encodedMiniStructIK)
        
        //encoder.encoder.showKeysForContainers = true  //default at time of writing.
        LC.encoder.indexKeyedArrays = false
        let encodedMiniStructUK = try await LC.encode(miniStructArray).utf8String
        let unindexedOutput = "[array:[54,45,67,89],numeral:4314124,string:world]\n[array:[54,45,67,89],numeral:4314124,string:world]\n[array:[54,45,67,89],numeral:4314124,string:world]\n[array:[54,45,67,89],numeral:4314124,string:world]\n[array:[54,45,67,89],numeral:4314124,string:world]"
        XCTAssertEqual(unindexedOutput, encodedMiniStructUK)
        
    }
    
    func testNestedArrays() async throws {
        let LC = LineCoder()
        let nestedArray = [[67,98], [2,3,4,5,6], [23,1,2,47732], [9]]
        let encodedNestedArray = try await LC.encode(nestedArray).utf8String
        XCTAssertEqual("[67,98]\n[2,3,4,5,6]\n[23,1,2,47732]\n[9]", encodedNestedArray)
    }
    
    func testDictionaries() async throws {
        let LC = LineCoder()
        
        
        
        let dictIS = [12:"twelve", 11:"eleven"]
        let dictISExpected = "[11:eleven,12:twelve]"
        let dictISEncode = try await LC.encode(dictIS).utf8String
        XCTAssertEqual(dictISExpected, dictISEncode)
        
        let evens = [12:"twelve", 10:"ten", 8:"eight"]
        let odds = [11:"eleven", 9:"nine", 7:"seven"]
        
        //LC.encoder.showKeysForContainers = false
        let nestDictIS = ["evens":evens, "odds":odds]
        let nestDictISExpected = "[evens:[evens.8:eight,evens.10:ten,evens.12:twelve],odds:[odds.7:seven,odds.9:nine,odds.11:eleven]]"
        let nestDictISEncode = try await LC.encode(nestDictIS).utf8String
        XCTAssertEqual(nestDictISExpected, nestDictISEncode)
    }
    
    func testEnum() async throws {
        let LC = LineCoder()
        
        enum FruitChoice:Codable {
            case strawberry, pineapple, dragon, kiwi, kumquat
        }
        let fruit:FruitChoice = .pineapple
        let fcEncode = try await LC.encode(fruit).utf8String
        
        
        //XCTAssertEqual("[67,98]\n[2,3,4,5,6]\n[23,1,2,47732]\n[9]", fcEncode)
        
        
//        let testStruct = WeirdItems()
//        let encodedWIS = try await LC.encode(testStruct).utf8String
//        
//        XCTAssertEqual("[67,98]\n[2,3,4,5,6]\n[23,1,2,47732]\n[9]", encodedWIS)
    }
}


fileprivate extension Data {
    var utf8String: String {
        String(bytes: self, encoding: .utf8)!
    }
}


final class LineCoderFromSO:XCTestCase {
    
    struct Product: Codable {
        var name: String
        var price: Float
        var info: String
    }
    
    struct Address: Codable {
        var street: String
        var city: String
        var state: String
    }
    
    struct Store: Codable {
        var name: String
        var address: Address // nested struct
        var products: [Product] // array
    }
    
    struct TestStruct:Codable {
        let number:Int
        let text:String
        let sub:TestSubStruct
    }
    
    struct TestSubStruct:Codable {
        let numeral:Int
        let string:String
    }
    
//    func testExample() throws {
//        let sub = TestSubStruct(numeral: 34, string: "world")
//        let testItem = TestStruct(number: 12, text: "hello", sub: sub)
//        XCTAssertEqual("12.hello", try DotStringMaker.encode(testItem))
//        
//    }
    
    func testSOTestOne() async throws {
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
//        let output = """
///* Generated by StringsEncoder */
//"info" = "Our best iPhone yet!";
//"name" = "iPhone X";
//"price" = "1000.0";
//"""
        let output2 = "[info:Our best iPhone yet!,name:iPhone X,price:1000]"
        
        let encoder = LineCoder()
        let stringsFile = try await encoder.encode(iPhone).utf8String
        
        XCTAssertEqual(output2, stringsFile)
        
    }
    
    func testSOTestTwo() async throws {
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
        let macBook = Product(name: "Mac Book Pro", price: 2_000, info: "Early 2019")
        let watch = Product(name: "Apple Watch", price: 500, info: "Series 4")
//        let output = """
///* Generated by StringsEncoder */
//"address.city" = "San Francisco";
//"address.state" = "CA";
//"address.street" = "300 Post Street";
//"name" = "Apple Store";
//"products.0.info" = "Our best iPhone yet!";
//"products.0.name" = "iPhone X";
//"products.0.price" = "1000.0";
//"products.1.info" = "Early 2019";
//"products.1.name" = "Mac Book Pro";
//"products.1.price" = "2000.0";
//"products.2.info" = "Series 4";
//"products.2.name" = "Apple Watch";
//"products.2.price" = "500.0";
//"""
        //label sub-objects, key arrays.
        let output2 = "[address:[address.city:San Francisco,address.state:CA,address.street:300 Post Street],name:Apple Store,products:[[products.0.info:Our best iPhone yet!,products.0.name:iPhone X,products.0.price:1000],[products.1.info:Early 2019,products.1.name:Mac Book Pro,products.1.price:2000],[products.2.info:Series 4,products.2.name:Apple Watch,products.2.price:500]]]"
        
        let appleStore = Store(
            name: "Apple Store",
            address: Address(street: "300 Post Street", city: "San Francisco", state: "CA"),
            products: [iPhone, macBook, watch]
        )
        
        let encoder = LineCoder()
        let stringsFile = try await encoder.encode(appleStore).utf8String
        XCTAssertEqual(output2, stringsFile)
        
    }
}
