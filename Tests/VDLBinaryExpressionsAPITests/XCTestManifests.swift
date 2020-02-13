import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryOperatorAssociativityTests.allTests),
        testCase(BinaryOperatorProtocolTests.allTests),
        testCase(BinaryOperatorExpressionTokenTests.allTests),
        testCase(RepresentableAsEmptyProtocolTests.allTests),
        testCase(API_evalTests.allTests),
        testCase(API_validateInfixChunckTests.allTests),
        testCase(API_convertToRPNTests.allTests),
        testCase(API_convertFromRPNToInfixTests.allTests),
        testCase(API_isValidInfixNotationTests.allTests),
        testCase(API_isValidPostfixNotationTests.allTests),
        testCase(API_evaluateTests.allTests),
        testCase(API_postfixByWithTests.allTests),
        testCase(API_validInfixTests.allTests),
        testCase(API_validPostfixTests.allTests),
        
    ]
}
#endif
