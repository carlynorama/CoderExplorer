//
//  File.swift
//  
//
//  Created by Carlyn Maw on 2/28/24.
//

import Foundation

struct FloatHandler {
    public enum NonConformingFloatEncodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Encode the values using the given representation strings.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
//    @inline(__always) fileprivate func wrapFloat<F: FloatingPoint & CustomStringConvertible>(_ float: F, for additionalKey: CodingKey?) throws -> JSONValue {
//           guard !float.isNaN, !float.isInfinite else {
//               if case .convertToString(let posInfString, let negInfString, let nanString) = self.options.nonConformingFloatEncodingStrategy {
//                   switch float {
//                   case F.infinity:
//                       return .string(posInfString)
//                   case -F.infinity:
//                       return .string(negInfString)
//                   default:
//                       // must be nan in this case
//                       return .string(nanString)
//                   }
//               }
//
//               var path = self.codingPath
//               if let additionalKey = additionalKey {
//                   path.append(additionalKey)
//               }
//
//               throw EncodingError.invalidValue(float, .init(
//                   codingPath: path,
//                   debugDescription: "Unable to encode \(F.self).\(float) directly in JSON."
//               ))
//           }
//
//           var string = float.description
//           if string.hasSuffix(".0") {
//               string.removeLast(2)
//           }
//           return .number(string)
//       }

}
