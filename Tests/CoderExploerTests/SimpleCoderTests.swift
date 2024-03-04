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
    
    func testExample() throws {
        let encoder = SimpleCoder()
        
            let sub = TestSubStruct(numeral: 34, string: "world")
            let testItem = TestStruct(number: 12, text: "hello", sub: sub)
        XCTAssertEqual("number:12/sub.numeral:34/sub.string:world/text:hello", try encoder.encode(testItem))
        
    }
    
    func testSOTestOne() throws {
        let encoder = SimpleCoder()
        
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
        let output = """
info:Our best iPhone yet!/name:iPhone X/price:1000.0
"""
            let stringsFile = try encoder.encode(iPhone)
            XCTAssertEqual(output, stringsFile)
        
    }
    
    func testSOTestTwo() throws {
        let encoder = SimpleCoder()
        
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
        let macBook = Product(name: "Mac Book Pro", price: 2_000, info: "Early 2019")
        let watch = Product(name: "Apple Watch", price: 500, info: "Series 4")
        let output = """
address.city:San Francisco/address.state:CA/address.street:300 Post Street/name:Apple Store/products.0.info:Our best iPhone yet!/products.0.name:iPhone X/products.0.price:1000.0/products.1.info:Early 2019/products.1.name:Mac Book Pro/products.1.price:2000.0/products.2.info:Series 4/products.2.name:Apple Watch/products.2.price:500.0
"""
        
        let appleStore = Store(
            name: "Apple Store",
            address: Address(street: "300 Post Street", city: "San Francisco", state: "CA"),
            products: [iPhone, macBook, watch]
        )

            let stringsFile = try encoder.encode(appleStore)
        XCTAssertEqual(output, stringsFile)
         
    }
    
    func testSingleValues() async throws {
        let LC = SimpleCoder()
        
        let toEncodeInt = Int.random(in: Int.min...Int.max)
        let toEncodeText = "hello" //TODO: make random strings to test encodings in a different function.
        let toEncodeBool = Bool.random()
        let toEncodeDouble = Double.random(in: Double.leastNonzeroMagnitude...Double.greatestFiniteMagnitude)
        let toEncodeFloat = Float.random(in: Float.leastNonzeroMagnitude...Float.greatestFiniteMagnitude)
        let toEncodeInt32 = Int32.random(in: Int32.min...Int32.max)
        
        //let toEncodeOptionalInt:Int? = nil
        
        
        let encodedInt = try await LC.encode(toEncodeInt)
        let encodedText = try await LC.encode(toEncodeText)
        let encodedBool = try await LC.encode(toEncodeBool)
        
        let encodedDouble = try await LC.encode(toEncodeDouble)
        let encodedFloat = try await LC.encode(toEncodeFloat)
        let encodedInt32 = try await LC.encode(toEncodeInt32)
        
        //let encodedOptionalInt = try await LC.encode(toEncodeOptionalInt)
        
        XCTAssertEqual(toEncodeInt.description, encodedInt)
        XCTAssertEqual(toEncodeText.description, encodedText)
        XCTAssertEqual(toEncodeBool.description, encodedBool)
        XCTAssertEqual(toEncodeDouble.description, encodedDouble)
        XCTAssertEqual(Double(toEncodeFloat).description, encodedFloat)
        XCTAssertEqual(toEncodeInt32.description, encodedInt32)
        //XCTAssertEqual(Data(LC.encoder.nullValueOutput), encodedOptionalInt)
        
//        let url = FileManager.default.homeDirectoryForCurrentUser
//        let date = Date()
//        let number = Decimal(78.326)
//        let data = Data([10, 15, 20])
//        
//        let dateString = date.ISO8601Format(.iso8601)
//        let urlString = url.absoluteString
//        let decimalString = number.description
//        let dataString = data.base64EncodedString()
//        
//        let encodedDate = try await LC.encode(date)
//        let encodedURL = try await LC.encode(url)
//        let encodedDecimal = try await LC.encode(number)
//        let encodedData = try await LC.encode(data)
//        
//        XCTAssertEqual(dateString, encodedDate)
//        XCTAssertEqual(urlString, encodedURL)
//        XCTAssertEqual(decimalString, encodedDecimal)
//        XCTAssertEqual(dataString, encodedData)
        
    }
    
}


