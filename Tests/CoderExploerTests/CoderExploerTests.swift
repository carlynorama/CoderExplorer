import XCTest
@testable import CoderExplorer


// MARK: - Helper Global Functions
fileprivate func expectEqualPaths(_ lhs: [CodingKey], _ rhs: [CodingKey], _ prefix: String) {
  if lhs.count != rhs.count {
    XCTFail("\(prefix) [CodingKey].count mismatch: \(lhs.count) != \(rhs.count)")
    return
  }

  for (key1, key2) in zip(lhs, rhs) {
    switch (key1.intValue, key2.intValue) {
    case (.none, .none): break
    case (.some(let i1), .none):
      XCTFail("\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != nil")
      return
    case (.none, .some(let i2)):
      XCTFail("\(prefix) CodingKey.intValue mismatch: nil != \(type(of: key2))(\(i2))")
      return
    case (.some(let i1), .some(let i2)):
        guard i1 == i2 else {
            XCTFail("\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != \(type(of: key2))(\(i2))")
            return
        }
    }

    XCTAssertEqual(key1.stringValue, key2.stringValue, "\(prefix) CodingKey.stringValue mismatch: \(type(of: key1))('\(key1.stringValue)') != \(type(of: key2))('\(key2.stringValue)')")
  }
}

// MARK: - Helper Types

/// A key type which can take on any string or integer value.
/// This needs to mirror _JSONKey.
fileprivate struct _TestKey : CodingKey {
  var stringValue: String
  var intValue: Int?

  init?(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = nil
  }

  init?(intValue: Int) {
    self.stringValue = "\(intValue)"
    self.intValue = intValue
  }

  init(index: Int) {
    self.stringValue = "Index \(index)"
    self.intValue = index
  }
}


final class CoderExplorerTests: XCTestCase {
    let encoder = SimpleCoder()
    
    private struct EncodeMe : Encodable {
        var keyName: String
        func encode(to coder: Encoder) throws {
            var c = coder.container(keyedBy: _TestKey.self)
            try c.encode("test", forKey: _TestKey(stringValue: keyName)!)
        }
    }
    
    private struct EncodeFailure : Encodable {
        var someValue: Double
    }

    private struct EncodeFailureNested : Encodable {
        var nestedValue: EncodeFailure
    }

    private struct EncodeNested : Encodable {
        let nestedValue: EncodeMe
    }

    private struct EncodeNestedNested : Encodable {
        let outerValue: EncodeNested
    }
    
    func testEncodingKeyStrategyPath() {
        let expected = ""
        let toTest = EncodeNestedNested(outerValue: EncodeNested(nestedValue: EncodeMe(keyName: "helloWorld")))
        let result = try! encoder.encode(toTest)
        XCTAssertEqual(expected, result)
    }
    
    private struct NestedContainersTestType : Encodable {
      let testSuperEncoder: Bool

      init(testSuperEncoder: Bool = false) {
        self.testSuperEncoder = testSuperEncoder
      }

      enum TopLevelCodingKeys : Int, CodingKey {
        case a
        case b
        case c
      }

      enum IntermediateCodingKeys : Int, CodingKey {
          case one
          case two
      }

      func encode(to encoder: Encoder) throws {
        if self.testSuperEncoder {
          var topLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
          expectEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
          expectEqualPaths(topLevelContainer.codingPath, [], "New first-level keyed container has non-empty codingPath.")

          let superEncoder = topLevelContainer.superEncoder(forKey: .a)
          expectEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
          expectEqualPaths(topLevelContainer.codingPath, [], "First-level keyed container's codingPath changed.")
          expectEqualPaths(superEncoder.codingPath, [TopLevelCodingKeys.a], "New superEncoder had unexpected codingPath.")
          _testNestedContainers(in: superEncoder, baseCodingPath: [TopLevelCodingKeys.a])
        } else {
          _testNestedContainers(in: encoder, baseCodingPath: [])
        }
      }

      func _testNestedContainers(in encoder: Encoder, baseCodingPath: [CodingKey]) {
        expectEqualPaths(encoder.codingPath, baseCodingPath, "New encoder has non-empty codingPath.")

        // codingPath should not change upon fetching a non-nested container.
        var firstLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
        expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
        expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "New first-level keyed container has non-empty codingPath.")

        // Nested Keyed Container
        do {
          // Nested container for key should have a new key pushed on.
          var secondLevelContainer = firstLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .a)
          expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "New second-level keyed container had unexpected codingPath.")

          // Inserting a keyed container should not change existing coding paths.
          let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .one)
          expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
          expectEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.one], "New third-level keyed container had unexpected codingPath.")

          // Inserting an unkeyed container should not change existing coding paths.
          let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer(forKey: .two)
          expectEqualPaths(encoder.codingPath, baseCodingPath + [], "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath + [], "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
          expectEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.two], "New third-level unkeyed container had unexpected codingPath.")
        }

        // Nested Unkeyed Container
        do {
          // Nested container for key should have a new key pushed on.
          var secondLevelContainer = firstLevelContainer.nestedUnkeyedContainer(forKey: .b)
          expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "New second-level keyed container had unexpected codingPath.")

          // Appending a keyed container should not change existing coding paths.
          let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self)
          expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
          expectEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 0)], "New third-level keyed container had unexpected codingPath.")

          // Appending an unkeyed container should not change existing coding paths.
          let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer()
          expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
          expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
          expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
          expectEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 1)], "New third-level unkeyed container had unexpected codingPath.")
        }
      }
    }

    
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}
