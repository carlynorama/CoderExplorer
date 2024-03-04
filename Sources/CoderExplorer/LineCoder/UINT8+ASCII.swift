//
//  File 2.swift
//  
//
//  Created by Carlyn Maw on 2/27/24.
//

import Foundation

//https://github.com/apple/swift-corelibs-foundation/blob/5a1db791ab824e29dc45ce08f729d3541f0517d0/Sources/Foundation/JSONSerialization%2BParser.swift#L622C1-L649C2
extension UInt8 {

    internal static let _space = UInt8(ascii: " ")
    internal static let _return = UInt8(ascii: "\r")
    internal static let _newline = UInt8(ascii: "\n")
    internal static let _tab = UInt8(ascii: "\t")

    internal static let _colon = UInt8(ascii: ":")
    internal static let _comma = UInt8(ascii: ",")
    internal static let _period = UInt8(ascii: ".") //added

    internal static let _openbrace = UInt8(ascii: "{")
    internal static let _closebrace = UInt8(ascii: "}")

    internal static let _openbracket = UInt8(ascii: "[")
    internal static let _closebracket = UInt8(ascii: "]")

    internal static let _quote = UInt8(ascii: "\"")
    internal static let _backslash = UInt8(ascii: "\\")

}

extension Array where Element == UInt8 {

    internal static let _true = [UInt8(ascii: "t"), UInt8(ascii: "r"), UInt8(ascii: "u"), UInt8(ascii: "e")]
    internal static let _false = [UInt8(ascii: "f"), UInt8(ascii: "a"), UInt8(ascii: "l"), UInt8(ascii: "s"), UInt8(ascii: "e")]
    internal static let _null = [UInt8(ascii: "n"), UInt8(ascii: "u"), UInt8(ascii: "l"), UInt8(ascii: "l")]
    internal static let _nil = [UInt8(ascii: "n"), UInt8(ascii: "i"), UInt8(ascii: "l")]
    internal static let _none = [UInt8(ascii: "n"), UInt8(ascii: "o"), UInt8(ascii: "n"), UInt8(ascii: "e")]

}
