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
    
    func testEnum() throws {
        let encoder = SimpleCoder()
        
        //Runs as String?
        enum Greeting:String,Codable {
            case hello, howdy, hola, hi, hiya
        }
        
        //Runs as nested.
//        enum FruitChoice:Codable {
//            case strawberry, pineapple, dragon, kiwi, kumquat
//        }
//        let fruit:FruitChoice = .pineapple
        
        //------------------ SingleValue
        let enumValue:Greeting = .hiya
        let expectedEnumString = "hiya"
        let encodedEnum = try encoder.encode(enumValue)
        XCTAssertEqual(expectedEnumString, encodedEnum)
        
        //------------------ SingleValue
//        let enumFruitValue:FruitChoice = .strawberry
//        let expectedEnumFruitString = "hiya"
//        let encodedFruitEnum = try encoder.encode(enumFruitValue)
//        XCTAssertEqual(expectedEnumFruitString, encodedFruitEnum)
        
        //--------- Keyed
        struct MiniWithEnum:Encodable {
            let otherValue:Double = 42
            let myGreeting:Greeting = .hello
            let otherStringValue = "world"
        }
        
        let miniToTest = MiniWithEnum()
        let structExpected = "myGreeting:\(miniToTest.myGreeting)"
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
    
    

    
}


