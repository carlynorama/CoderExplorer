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
            let sub = TestSubStruct(numeral: 34, string: "world")
            let testItem = TestStruct(number: 12, text: "hello", sub: sub)
        XCTAssertEqual("12.hello", try DotStringMaker.encode(testItem))
        
    }
    
    func testSOTestOne() throws {
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
        let output = """
/* Generated by StringsEncoder */
"info" = "Our best iPhone yet!";
"name" = "iPhone X";
"price" = "1000.0";
"""
            let stringsFile = try DotStringMaker.encode(iPhone)
            XCTAssertEqual(output, stringsFile)
        
    }
    
    func testSOTestTwo() throws {
        let iPhone = Product(name: "iPhone X", price: 1_000, info: "Our best iPhone yet!")
        let macBook = Product(name: "Mac Book Pro", price: 2_000, info: "Early 2019")
        let watch = Product(name: "Apple Watch", price: 500, info: "Series 4")
        let output = """
/* Generated by StringsEncoder */
"address.city" = "San Francisco";
"address.state" = "CA";
"address.street" = "300 Post Street";
"name" = "Apple Store";
"products.0.info" = "Our best iPhone yet!";
"products.0.name" = "iPhone X";
"products.0.price" = "1000.0";
"products.1.info" = "Early 2019";
"products.1.name" = "Mac Book Pro";
"products.1.price" = "2000.0";
"products.2.info" = "Series 4";
"products.2.name" = "Apple Watch";
"products.2.price" = "500.0";
"""
        
        
        let appleStore = Store(
            name: "Apple Store",
            address: Address(street: "300 Post Street", city: "San Francisco", state: "CA"),
            products: [iPhone, macBook, watch]
        )

            let stringsFile = try DotStringMaker.encode(appleStore)
        XCTAssertEqual(output, stringsFile)
         
    }
    
}
