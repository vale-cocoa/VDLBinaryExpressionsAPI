# VDLBinaryExpressionsAPI

An API for working with associative binary operation expressions.

## Introduction 
### Binary associative operations
Given A binary operation *f(T, T) -> T*, represented by the the operator `<*>` it said to be associative if for all `a,b,c` contained in *T* we have that `a <*> (b <*> c) = (a <*> b) <*> c`.

### Expressions and notations
Expressions representing binary operations on operands can be in either *infix* notation or *postfix* notation (a.k.a. Reverse Polish Notation). The latter is mainly used in computational systems.

#### Infix notation
The infix notation is what we use as humans the most for representing a binary expression: the *operator* is placed between the two *operands*:

**A + B * C**

Since operators can have different precedence in respect to each other, bracketing can be used in this notation form to change the order of evaluation:

**(A + B) * C**

Given the addition operator has less priority than the multiplication, then: 
*(A + B)* will be first evaluated in the latter case and then its result will be used as left operand for the multiplication; in the former case, instead, *B * C*  would be firstly evaluated, then its result would be used as right operand in the addition.

#### Postfix notation (a.k.a. Reverse Polish Notation)
In postfix notation the operators comes after the corresponding operands, therefore usage of parenthesis is not needed for determining the precedence of operators:

**A B C * +**

This would be postfix represention of the infix expression *A + B * C*, while:

**A B + C \** 

would be the postfix representation for the bracketed verision *(A + B) * C*.
This notation can be easily evaluated by using a stack.

## API Overview
### Binary expressions represented as collections of tokens
Expressions can be represented as collections of tokens, where each token is either an operand, an operator —or a bracket (opened/closed) for the infix notation. 

The position of each token inside the collection will match its position in the expression: that is a token at the first index of a collection is the leftmost in the expression.

### Functionalities by extension on `Collection` protocol
The public API add functionalities to `Collection<BinaryOperatorExpressionToken<T>>` providing instance methods for:

* validation/conversion of its content to an expression in either infix or postfix expression via:
    * `validInfix()` 
    * `validPostfix`
* combination into a postfix expression of its content via an operation with another expression via `postfixCombining(using:with:)`
*  evaluation of its content into the result for the represented expression via `evaluate()` —available when certain criteria are met.
* codability via `Codable` protocol of the expression —available when certain criteria are met.

### Building blocks
As mentioned before this API introduces instance methods on `Collection` with an `Element` of type `BinaryExpressionToken<T>`, which is the basic bulding block for these expressions.

#### `BinaryExpressionToken`
`BinaryExpressionToken<T>` is a generic `enum` which provides all the cases a token in a binary expression could be:
* `.operand(T.Operand)`: an operand
* `.binaryOperator(T)`: an operator
* `.openingBracket`: an opening bracket
* `.closingBracket`: a closing bracket

The generic `T` type used to specialize this generic `enum` must conform to `BinaryOperatorProtocol<Operand>`, a `protocol` which defines how an operator works on its associated type `Operand`, its priority and its kind of associativty. 

#### `BinaryOperatorProtocol`
As mentioned earlier `BinaryOperatorProtocol<Operand>` defines how a 
an operator works, and on what type of operand it works with.
Therefore it has to associate with a concrete type (generically referred as `Operand`) which it operates on by providing the binary operation it represents via its functional readonly property `binaryOperation`.
This property is a closure of type `(Operand, Operand) throws -> Operand`, hence a binary operation (which may fail throwing an `Error`).

It also provides the operator priority by its readonly property `priority`,  expressed by an `Int`. Higher values mean higher priority.

Finally it provides the associativity direction of the operator, by its readonly property `associativity` of type `BinaryOperatorAssociativity`, an `enum` with two cases: `.left` and `.right`.

##### `Codable` conformance
When a concrete type `T` implementing `BinaryOperatorProtocol` and its associated cocrete type `T.Operand` both conform to `Codable`, then the resulting `BinaryExpressionToken<T>` will also provide `Codable` conformance, making possible to encode/decode binary expressions of this kind. 

### Associativity direction for operators: `BinaryOperatorAssociativity`
This `enum` describes the associativity direction of a binary operator when evaluated an infix expression.
An operator is *left-associative* when the operations are grouped to the left in a chained expression evaluation.
On the contrary, an operator is *right-associative* when the operations are grouped to the right in a chained expression evaluation.

For example given the operator `<+>`, and the operands `a, b, c`:
* left-associative: `a <+> b <+> c == (a <+> b) <+> c` 
* right-associative: `a <+> b <+> c == a <+> (b <+> c)` 

Therefore the possible cases of this `enum` are:
* `.left` for *left-associative* operator
* `.right` for *right-associative* operator

#### `RepresentableAsEmptyProtocol`
When the `Operand` associated type also conforms to the API protocol `RepresentableAsEmptyProtocol`, then it will be possible to use the instance method `evaluate()` on `Collection<BinaryExpressionToken<T>>` .

A type conforming to `RepresentableAsEmptyProtocol` must provide an instance method `isEmpty()`, a `Bool` flag signaling that the instance is equal to the *"empty"* value, and a static method `empty()` which return the *"empty"* value for the conforming type.

For example making `String` conform to `RepresentableAsEmptyProtocol`:
```swift
extension String: RepresentableAsEmptyProtocol {
    public static func empty() -> String { return "" }
}
```
No need here to implement `isEmpty()` since `String` already provides it, which is also consistent with the implementation of the static method `empty() -> String`  we've just provided.

On the other hand making `Int` conform to `RepresentableAsEmptyProtcol`:
```swift 
extension Int: RepresentableAsEmptyProtocol {
    public static func empty() -> Int { return 0 }
    public func isEmpty() -> Bool { return self == Int.empty() }
}
```
Since `Int` doesn't provide an `isEmpty()` istance method, we must provide one which returns the comparsion between its value and the one returned by the static function `empty()`. Note that the value `0` was chosen because that would also be the value returned by evaluating an empty binary expression with integer numbers as operands… **This is why the API method `evaluate()` can be available on `Collection` of `BinaryExpressionToken<T: BinaryOperatorProtocol> where T.Operand: RepresentableAsEmptyProtocol`, cause that is how to evaluate empty collections.**

### Conversion between infix and postfix notation
The API allow to convert an expression between the two notation forms with the instance methods `validInfix()` and `validPostfix()`.
Both methods will return an `Array` whose `Element` is the same type as the `Collection.Iterator.Element` callee, in case it is a valid expression in any of the two notations. 

That is, given a collection of tokens whose order is a valid infix notation expression, `validInfix()` will return it as an array with the same elements in the same order, while  `validPostfix()` instead will return an array with the same operands and operator elements, ordered to form the equivalent expression in postfix notation.

On the other hand given a collection of tokens whose order is a valid postfix notation expression, `validInfix()` will return an array containing the same elements, but with their order changed —eventually with parenthesis tokens added when needed—, to form the equivalent expression in infix notation. While calling `validPostfix()` will return an array containing the same elements in the same order of the callee collection.

### Combining two postfix expressions into one
Building up a postfix expression could be a tricky task, since we are generally more used to work with the infix notation.
On the other hand postfix notation is way much easier for keeping track on how a binary expression is evaluated.

The method `postfixCombing(using:with:)` it's a useful tool for building up expressions in postfix notation: by providing an operator and another valid expression —in either infix or postfix notation. 
Both expressions will be turned into postfix notation and used as operands for the given operator, forming a unique valid postfix expression.

That is, given:
* `a, b, c, d` as operand tokens 
* `operatorX, operatorY, operatorZ` as operator tokens
* `zOperation` as the concrete instance of `BinaryOperatorProtocol` associated to token `operatorZ`
* `let lhs = [a, b, operatorX]` as a valid postfix expression
* `let rhs = [c, d, operatorY]` as another valid postfix expression

when: 
* `let new = try! lhs.postfixCombinig(using: operatorZ, with: rhs)`

then: 
* `assert(new == [a, b, operatorX, c, d, operatorY, operatorZ])`
* `let isNewValid = (new.validPostfix() != nil)`
* `assert(isValid == true)`


### Errors
#### Validation errors
Errors can be thrown when validation for the notation of the expression is performed. 
The type of error thrown in those circumstances is `BinaryExpressionError`, specifically the `.notValid` value.

Listed below are the API methods introduced on `Collection` that might throw a `BinaryExpressionError.notValid`: 

* `postfixCombinig(using:with:)`
* `evaluate()` 

Both methods need to perform a validation of the expression(s), in order to be able to compute their result. 

#### Evaluation errors
During the evaluation of an expression, when the expression is valid, an operator might fail and throw an error.

`evaluate()` will rethrow the `Error` thrown by the concrete type of `BinaryOperatorProtocol` associated to the expression token, when a binary operation fails while being applied to the operands in the expression during the result calculation. 

Note that `evaluate()` method will perform a validation check on the expresison before starting the result calcultaion, hence the validation error has priority over the failing operator error.

#### Methods returning `Nil` instead of throwing an error 
The methods `validInfix()` and `validPostfix()` won't throw an error if the callee expression is not in any valid notation, but rather return `nil`. 

## API usage example
Following is a trival example of usage of the API, which shows how to implement some functional binary operators on `String` operands and use them to build binary expression.

### Creating a concrete `BinaryOperatorProtocol` type
First we need to define a concrete `BinaryOperatorProtocol` type —named in this example `MyStringOperators`– which also associates to another concrete type used as `Operand` —in this example `String` since we are creating binary operators that work on strings.

Usually an `enum` would suit fine this purpose:

```swift
public enum MyStringOperators: BinaryOperatorProtocol {
    case shuffling
    case camelCasing
    
    enum Error: Swift.Error {
        case failure
    }
    
    static func shuffle(lhs: String, rhs: String) throws -> String {
        guard
            !lhs.isEmpty,
            !rhs.isEmpty
            else { throw Error.failure}
        
        return zip(lhs, rhs)
            .map { (String($0.0), String($0.1)) }
            .reduce("") { $0 + ($1.0 + $1.1) }
    }
    
    static func camelCase(lhs: String, rhs: String) throws -> String {
        guard
            !(lhs.isEmpty && rhs.isEmpty)
            else { return "" }
        
        let lhsCap = try _wordsCapitalized(on: lhs)
        let rhsCap = try _wordsCapitalized(on: rhs)
        let res = lhsCap + rhsCap
        let first = res.first!
        
        return (first.lowercased()) + (res.dropFirst())
    }
    
    private static func _wordsCapitalized(on string: String) throws -> String {
        guard
            !string.isEmpty
            else { throw Error.failure }
        
        return string
            .components(separatedBy: " ")
            .map { $0.lowercased() }
            .map { $0.capitalized }
            .joined()
    }
    
    // MARK: - BinaryOperatorProtocol conformance
    public typealias Operand = String
    
    public var binaryOperation: (String, String) throws -> String {
        switch self {
        case .shuffling: return Self.shuffle
        case .camelCasing: return Self.camelCase
        }
    }
    
    public var priority: Int {
        switch self {
        case .shuffling:
            return 10
        case.camelCasing:
            return 50
        }
    }
    
    public var associativity: BinaryOperatorAssociativity {
        switch self {
        case .shuffling:
            return .left
        case .camelCasing:
            return .left
        }
    }
    
}

extension String: RepresentableAsEmptyProtocol {
    public static func empty() -> String {
        return ""
    }
}
```
We've also made `String` conform to `RepresentableAsEmptyProtocol`, this way it will be possible to evaluate the expressions built upon the concrete binary operator. 
That is, `evaluate()` instance method will be available on `Collection<BinaryExpressionToken<MyStringOperators>>` . 

### Using `BinaryOperatorExpressionToken`
It is now possible to build and work on expressions of type `Collection<BinaryExpressionToken<MyStringOperators>>`:

```swift
typealias Token = BinaryOperatorExpressionToken<MyStringOperators>

let anInfix: [Token] = [
    .openingBracket, 
    .operand("Hello World!"), 
    .binaryOperator(.camelCasing), 
    .operand("This is a fun"), 
    .closingBracket, 
    .binaryOperator(.shuffling), 
    .operand("experiment")
]
```

### `Codable` conformance
By also having the concrete `BinaryOperatorProtocol` conform to `Codable`, it will be possible to effectively encode and then decode these binary expressions:

```swift
extension MyStringOperators: Codable {
    enum Base: String, Codable {
        case shufflingEncodedOperator
        case camelCaseEncodedOperator
        
        fileprivate var concrete: MyStringOperators {
            switch self {
            case .camelCaseEncodedOperator:
                return .camelCasing
            case .shufflingEncodedOperator:
                return .shuffling
            }
        }
    }
    
    fileprivate var base: Base {
        switch self {
        case .shuffling:
            return .shufflingEncodedOperator
        case .camelCasing:
            return .camelCaseEncodedOperator
        }
    }
    
    enum CodingKeys: CodingKey {
        case base
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        self = base.concrete
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.base, forKey: .base)
    }
    
}
```

## See also
* [Associativity and Commutativity of Binary Operations on mathonline.wikidot.com](http://mathonline.wikidot.com/associativity-and-commutativity-of-binary-operations)
* [Ray Wenderlich's Swift Algorithm Club - Shunting Yard ](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Shunting%20Yard)
* [Shunting Yard algorithm on Wikipedia](https://en.wikipedia.org/wiki/Shunting-yard_algorithm)
* [Operator Associativity on Wikipedia](https://en.wikipedia.org/wiki/Operator_associativity#Right-associativity_of_assignment_operators)
* [Converting postfix to infix on codeproject.com](https://www.codeproject.com/Articles/405361/Converting-Postfix-Expressions-to-Infix)
* [Monoids, semigroups and friends by Mark Seemann](https://blog.ploeh.dk/2017/10/05/monoids-semigroups-and-friends/)
