//
//  VDLBinaryExpressionsAPI
//  API_subInfixLhsByRhsTests.swift
//  
//
//  Created by Valeriano Della Longa on 14/02/2020.
//  Copyright (c) 2020 Valeriano Della Longa
//

import XCTest
@testable import VDLBinaryExpressionsAPI

final class API_subInfixLhsByRhsTests: XCTestCase {
    typealias SubInfix = _SubInfixExpression<MockBinaryOperator>
    typealias Token = BinaryOperatorExpressionToken<MockBinaryOperator>
    
    struct _Sut {
        var lhs: SubInfix = ([], nil)
        var rhs: SubInfix = ([], nil)
        var operation: MockBinaryOperator = .failingOperation
    }
    
    // MARK: - Properties
    var sut: _Sut!
    var result: SubInfix!
    var expectedResult: SubInfix!
    
    var mainLeftAssociativeOperators: [MockBinaryOperator] {
        MockBinaryOperator.allCases
            .filter {
                $0.associativity == .left && $0 != .failingOperation
        }
    }
    
    var mainRightAssociativeOperators: [MockBinaryOperator] {
        MockBinaryOperator.allCases
            .filter {
                $0.associativity == .right && $0 != .failingOperation
        }
    }
    
    var mainOperators: [MockBinaryOperator] {
        MockBinaryOperator.allCases
            .filter { $0 != .failingOperation }
    }
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = _Sut()
    }
    
    override func tearDown() {
        sut = nil
        result = nil
        expectedResult = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenEmpty() -> SubInfix {
        return ([], nil)
    }
    
    func givenNotValid() -> SubInfix {
        return ([.operand(10), .operand(30), .binaryOperator(.add)], .add)
    }
    
    func givenValidOperandOnly() -> SubInfix {
        let value = Int.random(in: 1...100)
        return ([.operand(value)], nil)
    }
    
    func givenValidBinaryAddition() -> SubInfix {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        return _validSubinfixForBinaryExpressionOf(lhs: lhs, rhs: rhs, operation: .add)
    }
    
    func givenValidBinaryMultiplication() -> SubInfix {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...100)
        return _validSubinfixForBinaryExpressionOf(lhs: lhs, rhs: rhs, operation: .multiply)
    }
    
    func givenValidBinarySubtraction() -> SubInfix {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 0..<lhs)
        return _validSubinfixForBinaryExpressionOf(lhs: lhs, rhs: rhs, operation: .subtract)
    }
    
    func givenValidBinaryDivision() -> SubInfix {
        let lhs = Int.random(in: 1...100)
        let rhs = Int.random(in: 1...lhs)
        return _validSubinfixForBinaryExpressionOf(lhs: lhs, rhs: rhs, operation: .divide)
    }
    
    func givenInBrackets(_ other: @escaping () -> SubInfix) -> SubInfix {
        let subInfix = other()
        let bracketed = _putBrackets(on: subInfix.expression)
        
        return (bracketed, subInfix.mainOperator)
    }
    
    func givenAllMainValidExpressions() -> [SubInfix] {
        
        return [
            givenValidBinaryAddition(),
            givenValidBinaryMultiplication(),
            givenValidBinarySubtraction(),
            givenValidBinaryDivision(),
        ]
    }
    
    // MARK: - Given helpers
    private func _validSubinfixForBinaryExpressionOf(lhs: Int, rhs: Int, operation: MockBinaryOperator) -> SubInfix {
        return ([.operand(lhs), .binaryOperator(operation), .operand(rhs)], operation)
    }
    
    // MARK: - When
    func whenEmpty() -> [() -> Void] {
        var closures = [() -> Void]()
        
        closures.append {
            self.sut.lhs = self.givenEmpty()
            self.sut.rhs = self.givenValidBinaryAddition()
            self.sut.operation = .add
        }
        
        closures.append {
            self.sut.lhs = self.givenValidBinaryAddition()
            self.sut.rhs = self.givenEmpty()
            self.sut.operation = .add
        }
        
        closures.append {
            self.sut.lhs = self.givenEmpty()
            self.sut.rhs = self.givenEmpty()
            self.sut.operation = .add
        }
        
        return closures
    }
    
    func whenNotValidInfix() -> [() -> Void] {
        var closures = [() -> Void]()
        
        closures.append {
            self.sut.lhs = self.givenNotValid()
            self.sut.rhs = self.givenValidBinaryAddition()
            self.sut.operation = .add
        }
        
        closures.append {
            self.sut.lhs = self.givenValidBinaryAddition()
            self.sut.rhs = self.givenNotValid()
            self.sut.operation = .add
        }
        
        closures.append {
            self.sut.lhs = self.givenNotValid()
            self.sut.rhs = self.givenNotValid()
            self.sut.operation = .add
        }
        
        return closures
    }
    
    func whenLhsOperandRhsOperand() -> [() -> Void] {
        var closures = [() -> Void]()
        
        for anOp in MockBinaryOperator.allCases {
            closures.append {
                // A, operator, B
                self.sut.lhs = self.givenValidOperandOnly()
                self.sut.rhs = self.givenValidOperandOnly()
                self.sut.operation = anOp
                self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                
                // A operator B
                self.expectedResult = self._expectedValidResultFromActualSUT()
            }
        }
        
        return closures
    }
    
    func whenLhsOperandOperationLeftAssociativeRhsExpressionAnyAssociativity() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let operand = givenValidOperandOnly()
        let allValidExpressions = givenAllMainValidExpressions()
        
        for anOp in self.mainLeftAssociativeOperators {
            for anExpression in allValidExpressions {
                closures.append {
                    // A, +, B+C
                    // A, +, B*C
                    // A, +, B-C
                    // A, +, B/C
                    // A, *, B+C
                    // A, *, B*C
                    // A, *, B-C
                    // A, *, B/C
                    self.sut.lhs = operand
                    self.sut.rhs = anExpression
                    self.sut.operation = anOp
                    self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                    
                    // A + B + C
                    // A + B * C
                    // A + B - C
                    // A + B / C
                    // A * (B + C)
                    // A * B * C
                    // A * (B - C)
                    // A * B / C
                    self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnRhs: anOp.priority > anExpression.mainOperator!.priority)
                }
            }
        }
        
        return closures
    }
    
    func whenLhsOperandOperationRightAssociativeRhsExpressionAnyAssociativity() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let operand = givenValidOperandOnly()
        let allValidExpressions = givenAllMainValidExpressions()
        
        for anOp in self.mainRightAssociativeOperators {
            for anExpression in allValidExpressions {
                closures.append {
                    // A, -, B+C
                    // A, -, B*C
                    // A, -, B-C
                    // A, -, B/C
                    // A, /, B+C
                    // A, /, B*C
                    // A, /, B-C
                    // A, /, B/C
                    self.sut.lhs = operand
                    self.sut.rhs = anExpression
                    self.sut.operation = anOp
                    self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                    
                    // A - (B + C)
                    // A - (B * C)
                    // A - (B - C)
                    // A - (B / C)
                    // A / (B + C)
                    // A / (B * C)
                    // A / (B - C)
                    // A / (B / C)
                    self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnRhs: anOp.priority >= anExpression.mainOperator!.priority)
                }
            }
        }
        
        return closures
    }
    
    func whenLhsExpressionAnyAssociativityOperationAnyAssociativityRhsIsOperand() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let operand = givenValidOperandOnly()
        let allValidExpressions = givenAllMainValidExpressions()
        
        for anOp in self.mainOperators {
            for anExpression in allValidExpressions {
                closures.append {
                    // A+B, +, C
                    // A+B, *, C
                    // A+B, -, C
                    // A+B, /, C
                    // A*B, +, C
                    // A*B, *, C
                    // A*B, -, C
                    // A*B, /, C
                    // A-B, +, C
                    // A-B, *, C
                    // A-B, -, C
                    // A-B, /, C
                    // A/B, +, C
                    // A/B, *, C
                    // A/B, -, C
                    // A/B, /, C
                    self.sut.lhs = anExpression
                    self.sut.rhs = operand
                    self.sut.operation = anOp
                    self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                    
                    // A + B + C
                    // (A + B) * C
                    // A + B - C
                    // (A + B) / C
                    // A * B + C
                    // A * B * C
                    // A * B - C
                    // A * B / C
                    // A - B + C
                    // (A - B) * C
                    // A - B - C
                    // (A - B) / C
                    // A / B + C
                    // A / B * C
                    // A / B - C
                    // A / B / C
                    self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnLhs: anOp.priority > anExpression.mainOperator!.priority)
                }
            }
        }
        
        return closures
    }
    
    func whenLhsIsAnyExpressionOperationIsLeftAssociativeRhsIsAnyExpression() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let lhsExpressions = givenAllMainValidExpressions().shuffled()
        let rhsExpressions = givenAllMainValidExpressions().shuffled()
        for anOp in mainLeftAssociativeOperators {
            for lhs in lhsExpressions {
                for rhs in rhsExpressions {
                    closures.append {
                        // A+B, +, C+D
                        // A+B, +, C*D
                        // A+B, +, C-D
                        // A+B, +, C/D
                        // A*B, +, C+D
                        // A*B, +, C*D
                        // A*B, +, C-D
                        // A*B, +, C/D
                        // A-B, +, C+D
                        // A-B, +, C*D
                        // A-B, +, C-D
                        // A-B, +, C/D
                        // A/B, +, C+D
                        // A/B, +, C*D
                        // A/B, +, C-D
                        // A/B, +, C/D
                        // A+B, *, C+D
                        // A+B, *, C*D
                        // A+B, *, C-D
                        // A+B, *, C/D
                        // A*B, *, C+D
                        // A*B, *, C*D
                        // A*B, *, C-D
                        // A*B, *, C/D
                        // A-B, *, C+D
                        // A-B, *, C*D
                        // A-B, *, C-D
                        // A-B, *, C/D
                        // A/B, *, C+D
                        // A/B, *, C*D
                        // A/B, *, C-D
                        // A/B, *, C/D
                        self.sut.lhs = lhs
                        self.sut.rhs = rhs
                        self.sut.operation = anOp
                        self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                        
                        // A + B + C + D
                        // A + B + C * D
                        // A + B + C - D
                        // A + B + C / D
                        // A * B + C + D
                        // A * B + C * D
                        // A * B + C - D
                        // A * B + C / D
                        // A - B + C + D
                        // A - B + C * D
                        // A - B + C - D
                        // A - B + C / D
                        // A / B + C + D
                        // A / B + C * D
                        // A / B + C - D
                        // A / B + C / D
                        // A + B * C + D
                        // (A + B) * C * D
                        // (A + B) * (C - D)
                        // (A + B) * C / D
                        // A * B * (C + D)
                        // A * B * C * D
                        // A * B * (C - D)
                        // A * B * C / D
                        // (A - B) * (C + D)
                        // /A - B) * C * D
                        // (A - B) * (C - D)
                        // (A - B) * C / D
                        // A / B * (C + D)
                        // A / B * C * D
                        // A / B * (C - D)
                        // A / B * C / D
                        self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnLhs: anOp.priority > lhs.mainOperator!.priority, putBracketsOnRhs: anOp.priority > rhs.mainOperator!.priority)
                    }
                }
            }
        }
        
        return closures
    }
    
    func whenLhsIsAnyExpressionOperationIsRightAssociativeRhsIsAnyExpression() -> [() -> Void] {
        var closures = [() -> Void]()
        
        let lhsExpressions = givenAllMainValidExpressions().shuffled()
        let rhsExpressions = givenAllMainValidExpressions().shuffled()
        for anOp in mainRightAssociativeOperators {
            for lhs in lhsExpressions {
                for rhs in rhsExpressions {
                    closures.append {
                        // A+B, -, C+D
                        // A+B, -, C*D
                        // A+B, -, C-D
                        // A+B, -, C/D
                        // A*B, -, C+D
                        // A*B, -, C*D
                        // A*B, -, C-D
                        // A*B, -, C/D
                        // A-B, -, C+D
                        // A-B, -, C*D
                        // A-B, -, C-D
                        // A-B, -, C/D
                        // A/B, -, C+D
                        // A/B, -, C*D
                        // A/B, -, C-D
                        // A/B, -, C/D
                        // A+B, /, C+D
                        // A+B, /, C*D
                        // A+B, /, C-D
                        // A+B, /, C/D
                        // A*B, /, C+D
                        // A*B, /, C*D
                        // A*B, /, C-D
                        // A*B, /, C/D
                        // A-B, /, C+D
                        // A-B, /, C*D
                        // A-B, /, C-D
                        // A-B, /, C/D
                        // A/B, /, C+D
                        // A/B, /, C*D
                        // A/B, /, C-D
                        // A/B, /, C/D
                        self.sut.lhs = lhs
                        self.sut.rhs = rhs
                        self.sut.operation = anOp
                        self.result = try! _subInfix(lhs: self.sut.lhs, by: anOp, rhs: self.sut.rhs)
                        
                        // A + B - (C + D)
                        // A + B - C * D
                        // A + B - (C - D)
                        // A + B - C / D
                        // A * B - (C + D)
                        // A * B - C * D
                        // A * B - (C - D)
                        // A * B - C / D
                        // A - B - (C + D)
                        // A - B - C * D
                        // A - B - (C - D)
                        // A - B - C / D
                        // A / B - (C + D)
                        // A / B - C * D
                        // A / B - (C - D)
                        // A / B - C / D
                        // (A + B) / (C + D)
                        // (A + B) / (C * D)
                        // (A + B) / (C - D)
                        // (A + B) / (C / D)
                        // A * B / (C + D)
                        // A * B / (C * D)
                        // A * B / (C - D)
                        // A * B / (C / D)
                        // (A - B) / (C + D)
                        // /A - B) / (C * D)
                        // (A - B) / (C - D)
                        // (A - B) / (C / D)
                        // A / B / (C + D)
                        // A / B / (C * D)
                        // A / B / (C - D)
                        // A / B / (C / D)
                        self.expectedResult = self._expectedValidResultFromActualSUT(putBracketsOnLhs: anOp.priority > lhs.mainOperator!.priority, putBracketsOnRhs: anOp.priority >= rhs.mainOperator!.priority)
                    }
                }
            }
        }
        
        return closures
    }
    
    // MARK: - When helpers
    private func _expectedValidResultFromActualSUT(putBracketsOnLhs: Bool = false, putBracketsOnRhs: Bool = false) -> SubInfix {
        let lhsExpr = putBracketsOnLhs ? _putBrackets(on: sut.lhs.expression) : sut.lhs.expression
        let rhsExpr = putBracketsOnRhs ? _putBrackets(on: sut.rhs.expression) : sut.rhs.expression
        let expr = lhsExpr + [.binaryOperator(sut.operation)] + rhsExpr
        
        return (expr, sut.operation)
    }
    
    private func _putBrackets(on infixExpression: [Token])
        -> [Token]
    {
        
        return [.openingBracket] + infixExpression + [.closingBracket]
    }
    
    // MARK: - Then
    func thenResultIsEqualToExpectedResult() {
        
        XCTAssertEqual(result.expression, expectedResult.expression)
        XCTAssertEqual(result.mainOperator, expectedResult.mainOperator)
    }
    
    // MARK: - Tests
    func test_whenEmpty_throws() {
        // given
        let whenClosures = whenEmpty()
        
        // when
        for when in whenClosures {
            when()
            // then
            XCTAssertThrowsError(try _subInfix(lhs: sut.lhs, by: sut.operation, rhs: sut.rhs))
        }
    }
    
    func test_whenNotValidInfix_throws() {
        // given
        let whenClosures = whenNotValidInfix()
        
        // when
        for when in whenClosures {
            when()
            // then
            XCTAssertThrowsError(try _subInfix(lhs: sut.lhs, by: sut.operation, rhs: sut.rhs))
        }
    }
    
    func test_whenNotEmptyAndValidInfix_doesentThrow() {
        // given
        // when
        // then
        XCTAssertNoThrow(try _subInfix(lhs: givenValidBinaryAddition(), by: .add, rhs: givenValidBinaryAddition()))
    }
    // MARK: - testing LHS is operand, RHS is operand
    func test_whenLhsOperandRhsOperand_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsOperandRhsOperand()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
    }
    
    // MARK: - LHS is operand, RHS is expression
    func test_whenLhsOperandOperationLeftAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsOperandOperationLeftAssociativeRhsExpressionAnyAssociativity()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
    }
    func test_whenLhsOperandOperationRightAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsOperandOperationRightAssociativeRhsExpressionAnyAssociativity()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
    }
    
    // MARK: - LHS is expression, RHS is operand
    func test_whenLhsExpressionAnyAssociativityOperationAnyAssociativityRhsIsOperand_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsExpressionAnyAssociativityOperationAnyAssociativityRhsIsOperand()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
        
    }
    
    // MARK: - LHS is expression, RHS is expression
    func test_whenLhsIsAnyExpressionOperationIsLeftAssociativeRhsIsAnyExpression_returnsExpectedResult() {
        // given
        let whenClosures = whenLhsIsAnyExpressionOperationIsLeftAssociativeRhsIsAnyExpression()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
    }
    
    func test_whenLhsIsAnyExpressionOperationIsRightAssociativeRhsIsAnyExpression() {
        // given
        let whenClosures = whenLhsIsAnyExpressionOperationIsRightAssociativeRhsIsAnyExpression()
        
        // when
        for when in whenClosures {
            when()
            
            // then
            thenResultIsEqualToExpectedResult()
        }
    }
    
    // MARK: - _putBrackets specific tests
    func test_whenAlreadyBracketedAndShouldBracket_DoesntPutBrackets() {
        // when
        sut.lhs = givenInBrackets(givenValidBinaryAddition)
        sut.rhs = givenValidOperandOnly()
        sut.operation = .multiply
        result = try! _subInfix(lhs: sut.lhs, by: sut.operation, rhs: sut.rhs)
        let expectedExpression = sut.lhs.expression + [.binaryOperator(sut.operation)] + sut.rhs.expression
        expectedResult = (expectedExpression, sut.operation)
        
        // then
        thenResultIsEqualToExpectedResult()
    }
    
    func test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets() {
        // when
        sut.rhs = try! _subInfix(lhs: givenValidBinaryAddition(), by: .multiply, rhs: givenValidBinaryAddition())
        sut.lhs = givenValidBinaryAddition()
        sut.operation = .divide
        result = try! _subInfix(lhs: sut.lhs, by: sut.operation, rhs: sut.rhs)
        expectedResult = _expectedValidResultFromActualSUT(putBracketsOnLhs: true, putBracketsOnRhs: true)
        
        // then
        thenResultIsEqualToExpectedResult()
    }
    
    static var allTests = [
        ("test_whenEmpty_throws", test_whenEmpty_throws),
        ("test_whenNotValidInfix_throws", test_whenNotValidInfix_throws),
        ("test_whenLhsOperandRhsOperand_returnsExpectedResult", test_whenLhsOperandRhsOperand_returnsExpectedResult),
        ("test_whenLhsOperandOperationLeftAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult", test_whenLhsOperandOperationLeftAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult),
        ("test_whenLhsOperandOperationRightAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult", test_whenLhsOperandOperationRightAssociativeRhsExpressionAnyAssociativity_returnsExpectedResult),
        ("test_whenLhsExpressionAnyAssociativityOperationAnyAssociativityRhsIsOperand_returnsExpectedResult", test_whenLhsExpressionAnyAssociativityOperationAnyAssociativityRhsIsOperand_returnsExpectedResult),
        ("test_whenLhsIsAnyExpressionOperationIsLeftAssociativeRhsIsAnyExpression_returnsExpectedResult", test_whenLhsIsAnyExpressionOperationIsLeftAssociativeRhsIsAnyExpression_returnsExpectedResult),
        ("test_whenLhsIsAnyExpressionOperationIsRightAssociativeRhsIsAnyExpression", test_whenLhsIsAnyExpressionOperationIsRightAssociativeRhsIsAnyExpression),
        ("test_whenAlreadyBracketedAndShouldBracket_DoesntPutBrackets", test_whenAlreadyBracketedAndShouldBracket_DoesntPutBrackets),
        ("test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets", test_whenExpressionContainsBracketedExpressionAndShouldBracket_doesPutBrackets),
        
    ]
    
}
