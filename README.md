# VDLBinaryExpressionsAPI

An API for working with associative binary operation expressions.

## Introduction 
### Binary associative operations
Given A binary operation *f(T,T) -> T*, represented by the the operator `<*>` it said to be associative if for all `a,b,c` contained in *T* we have that `a <*> (b <*> c) = (a <*> b) <*> c`.

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
**A B + C &ast;** 
would be the postfix representation for the bracketed verision *(A + B) * C*.
This notation can be easily evaluated by a compiutational systems by using a stack.

## General API description
The public API add functionalities to `Collection` for validating its content as an associative binary operation expression in either infix or postfix expression, respectively with `validInfix()` and `validPostfix` instance methods.
Instance method `postfixCombinig(using:with:)` can be used to create a new expression in postfix notation resulting from applying the given operation to the callee and another given expression. 
Finally, the instance function `evaluate()` can be used to evaluate an expression to its result.


