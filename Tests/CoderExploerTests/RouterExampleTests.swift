////
////  File.swift
////  
////
////  Created by Carlyn Maw on 2/29/24.
////
//
//import XCTest
//@testable import CoderExplorer
//
//final class CodableRoutingTests: XCTestCase {
//    func testExample() throws {
//        XCTAssertEqual(try Router.encode(Route.home), "/home")
//        XCTAssertEqual(try Router.encode(Route.profile(5)), "/profile/5")
//        XCTAssertEqual(try Router.encode(Route.nested(.foo)), "/nested/foo")
//        XCTAssertEqual(try Router.encode(Route.nested(nil)), "/nested")
//        
//        XCTAssertEqual(try Router.decode("/home"), Route.home)
//        XCTAssertEqual(try Router.decode("/profile/5"), Route.profile(5))
//        XCTAssertEqual(try Router.decode("/nested/foo"), Route.nested(.foo))
//        XCTAssertEqual(try Router.decode("/nested"), Route.nested(nil))
//    }
//}
