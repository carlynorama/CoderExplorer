//
//  File 2.swift
//  
//
//  Created by Carlyn Maw on 2/27/24.
//

import Foundation


//JSON Needs some very specific things.
//https://datatracker.ietf.org/doc/html/rfc8259#section-7
//"Lines" don't?  See original function. Line 1109 in JSONEncoder.swift
//This will force everything to be UTF8. For lines that should be an _option_.
//        private func encodeString(_ string: String, to bytes: inout [UInt8]) {
//                    //bytes.append(UInt8(ascii: "\""))
//                    let stringBytes = string.utf8
//                    var startCopyIndex = stringBytes.startIndex
//                    var nextIndex = startCopyIndex
//
//                    while nextIndex != stringBytes.endIndex {
//                        switch stringBytes[nextIndex] {
//                        case 0 ..< 32, UInt8(ascii: "\""), UInt8(ascii: "\\"):
//                            // All Unicode characters may be placed within the
//                            // quotation marks, except for the characters that MUST be escaped:
//                            // quotation mark, reverse solidus, and the control characters (U+0000
//                            // through U+001F).
//                            // https://tools.ietf.org/html/rfc8259#section-7
//
//                            // copy the current range over
//                            bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
//                            switch stringBytes[nextIndex] {
//                            case UInt8(ascii: "\""): // quotation mark
//                                bytes.append(contentsOf: [._backslash, ._quote])
//                            case UInt8(ascii: "\\"): // reverse solidus
//                                bytes.append(contentsOf: [._backslash, ._backslash])
//                            case 0x08: // backspace
//                                bytes.append(contentsOf: [._backslash, UInt8(ascii: "b")])
//                            case 0x0C: // form feed
//                                bytes.append(contentsOf: [._backslash, UInt8(ascii: "f")])
//                            case 0x0A: // line feed
//                                bytes.append(contentsOf: [._backslash, UInt8(ascii: "n")])
//                            case 0x0D: // carriage return
//                                bytes.append(contentsOf: [._backslash, UInt8(ascii: "r")])
//                            case 0x09: // tab
//                                bytes.append(contentsOf: [._backslash, UInt8(ascii: "t")])
//                            default:
//                                func valueToAscii(_ value: UInt8) -> UInt8 {
//                                    switch value {
//                                    case 0 ... 9:
//                                        return value + UInt8(ascii: "0")
//                                    case 10 ... 15:
//                                        return value - 10 + UInt8(ascii: "a")
//                                    default:
//                                        preconditionFailure()
//                                    }
//                                }
//                                bytes.append(UInt8(ascii: "\\"))
//                                bytes.append(UInt8(ascii: "u"))
//                                bytes.append(UInt8(ascii: "0"))
//                                bytes.append(UInt8(ascii: "0"))
//                                let first = stringBytes[nextIndex] / 16
//                                let remaining = stringBytes[nextIndex] % 16
//                                bytes.append(valueToAscii(first))
//                                bytes.append(valueToAscii(remaining))
//                            }
//
//                            nextIndex = stringBytes.index(after: nextIndex)
//                            startCopyIndex = nextIndex
////                        case UInt8(ascii: "/") where options.contains(.withoutEscapingSlashes) == false:
////                            bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
////                            bytes.append(contentsOf: [._backslash, UInt8(ascii: "/")])
////                            nextIndex = stringBytes.index(after: nextIndex)
////                            startCopyIndex = nextIndex
//                        default:
//                            nextIndex = stringBytes.index(after: nextIndex)
//                        }
//                    }
//
//                    // copy everything, that hasn't been copied yet
//                    bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
//                    bytes.append(UInt8(ascii: "\""))
//                }
//            }
