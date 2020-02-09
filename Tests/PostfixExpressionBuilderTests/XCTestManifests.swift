import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryOperatorAssociativityTests.allTests),
        testCase(BinaryOperatorProtocolTests.allTests),
        testCase(BinaryOperatorExpressionTokenTests.allTests),
        testCase(RepresentableAsEmptyProtocolTests.allTests),
        testCase(API_addBracketsTests.allTests),
        testCase(API_evalTests.allTests),
        testCase(API_validateInfixChunckTests.allTests),
        testCase(API_convertToRPNTests.allTests),
        testCase(API_convertFromRPNToInfixTests.allTests),
        
    ]
}
#endif
