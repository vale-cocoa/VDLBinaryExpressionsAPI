import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryOperatorAssociativityTests.allTests),
        testCase(BinaryOperatorProtocolTests.allTests),
        testCase(BinaryOperatorExpressionTokenTests.allTests),
        testCase(RepresentableAsEmptyProtocolTests.allTests),
        testCase(AnyBinaryOperatorTests.allTests),
        testCase(API_subInfixFromInfixTests.allTests),
        testCase(API_subInfixLhsByRhsTests.allTests),
        testCase(API_evalTests.allTests),
        testCase(API_validateInfixChunckTests.allTests),
        testCase(API_convertToRPNTests.allTests),
        testCase(API_convertFromRPNToInfixTests.allTests),
        testCase(API_isValidInfixNotationTests.allTests),
        testCase(API_isValidPostfixNotationTests.allTests),
        testCase(API_evaluateTests.allTests),
        testCase(API_postfixByWithTests.allTests),
        testsCase(API_infixByWithTests.allTests),
        testCase(API_validInfixTests.allTests),
        testCase(API_validPostfixTests.allTests),
        
    ]
}
#endif
