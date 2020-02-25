import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryOperatorAssociativityTests.allTests),
        testCase(BinaryOperatorProtocolTests.allTests),
        testCase(BinaryOperatorExpressionTokenTests.allTests),
        testCase(RepresentableAsEmptyProtocolTests.allTests),
        testCase(AnyBinaryOperatorTests.allTests),
        testCase(ValidPostfixTests.allTests),
        testCase(ValidInfixTests.allTests),
        testCase(InfixByWithTests.allTests),
        testCase(EvaluatedTests.allTests),
        testCase(PostfixEvaluationByMappingTests.allTests),
        testCase(PostfixValidationTests.allTests),
        testCase(PostfixConversionTests.allTests),
        testCase(InfixConversionTests.allTests),
        
    ]
}
#endif
