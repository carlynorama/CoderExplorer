//
//  File.swift
//
//
//  Created by Carlyn Maw on 2/28/24.
//


class LCEncoderData<Output:Equatable & Hashable> {
    enum LCEncodedValue: Equatable {
        case string(Output)
        case number(Output)
        case bool(Bool)
        case null
        
        case array([LCEncodedValue])
        case object([Output: LCEncodedValue])
    }
    
    var current: LCWIP?
    
    var value: LCEncodedValue? {
        if let current {
            switch current {
            case .value(let value):
                return value
            case .nestedObject(let object):
                return .object(object.values)
            case .nestedArray(let array):
                return .array(array.values)
            }
        } else {
            return nil
        }
    }
    
    enum LCWIP {
        case value(LCEncodedValue)
        case nestedArray(ArrayBox)
        case nestedObject(ObjectBox)
    }
    
    func update(_ value: LCEncodedValue, for key: Output) throws {
        if current == nil {
            current =  .nestedObject(ObjectBox())
        }
        
        if let current {
            switch current {
                
            case .value(_):
                fatalError("\(String(describing: current)), handle existing mismatched container")
            case .nestedArray(let array):
                let object = array.appendObject()
                object.set(value, for: key)
            case .nestedObject(let object):
                object.set(value, for: key)
            }
        }
        
        
    }
    
    func update(_ value: LCEncodedValue) throws {
        //TODO: consequences of nuking from orbit?
        current = .value(value)
    }
    
    func append(_ value: LCEncodedValue) throws {
        if current == nil {
            current =  .nestedArray(ArrayBox())
        }
        
        if let current {
            switch current {
            case .value(_):
                fatalError("\(String(describing: current)), handle existing mismatched container")
            case .nestedArray(let array):
                array.append(value)
            case .nestedObject(let object):
                fatalError("\(String(describing: object)), handle existing mismatched container")
            }
        }
    }
    
    final class ObjectBox {
        private(set) var dict: [Output:LCWIP] = [:]
        init() {
            //self.dict.reserveCapacity(20)
        }
        
        @inline(__always) func set(_ value: LCEncodedValue, for key: Output) {
            self.dict[key] = .value(value)
        }
        
        var values: [Output: LCEncodedValue] {
            self.dict.mapValues { (future) -> LCEncodedValue in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return .array(array.values)
                case .nestedObject(let object):
                    return .object(object.values)
                }
            }
        }
        
    }
    
    class ArrayBox {
        private(set) var array: [LCWIP] = []
        
        init() {
            //self.array.reserveCapacity(10)
        }
        
        @inline(__always) func append(_ element: LCEncodedValue) {
            self.array.append(.value(element))
        }
        
        @inline(__always) func appendArray() -> ArrayBox {
            let array = ArrayBox()
            self.array.append(.nestedArray(array))
            return array
        }
        
        @inline(__always) func appendObject() -> ObjectBox {
            let object = ObjectBox()
            self.array.append(.nestedObject(object))
            return object
        }
        
        var values: [LCEncodedValue] {
            self.array.map { (future) -> LCEncodedValue in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return .array(array.values)
                case .nestedObject(let object):
                    return .object(object.values)
                }
            }
        }
    }
}


extension LCEncoderData.LCEncodedValue {
    var isValue: Bool {
        switch self {
        case .array, .object:
            return false
        case .null, .number, .string, .bool:
            return true
        }
    }
    
    var isContainer: Bool {
        switch self {
        case .array, .object:
            return true
        case .null, .number, .string, .bool:
            return false
        }
    }
    
    var debugDataTypeDescription: String {
        switch self {
        case .array:
            return "an array"
        case .bool:
            return "bool"
        case .number:
            return "a number"
        case .string:
            return "a string"
        case .object:
            return "a dictionary"
        case .null:
            return "null"
        }
    }
}
