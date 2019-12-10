//
//  Operators.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

precedencegroup RightApplyPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

precedencegroup LeftApplyPrecedence {
    associativity: left
    higherThan: RightApplyPrecedence
    lowerThan: TernaryPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup FunctionCompositionPrecedence {
    associativity: right
    higherThan: ApplicativePrecedence
}

precedencegroup LensSetPrecedence {
    associativity: left
    higherThan: FunctionCompositionPrecedence
}

/// Lens set
infix operator .~: LensSetPrecedence

/// Pipe forward function application
infix operator |>: LeftApplyPrecedence

/// Infix, flipped version of fmap (for optionals), i.e. `x ?|> f := f <^> x`
infix operator ?|>: LeftApplyPrecedence

/**
 Pipe a value into a function.

 - parameter x: A value.
 - parameter f: A function

 - returns: The value from apply `f` to `x`.
 */
func |> <A, B> (_ x: A, _ f: (A) -> B) -> B {
    return f(x)
}

/**
Pipe an optional value into a function, i.e. a flipped-infix operator for `map`.

- parameter x: An optional value.
- parameter f: A transformation.

- returns: An optional transformed value.
*/
func ?|> <A, B>(_ x: A?, _ f: (A) -> B) -> B? {
    return x.map(f)
}

/**
 Infix operator of the `set` function.

 - parameter lens: A lens.
 - parameter part: A part.

 - returns: A function that transforms a whole into a new whole with a part replaced.
 */
func .~ <Whole, Part> (lens: Lens<Whole, Part>, part: Part) -> ((Whole) -> Whole) {
    return { whole in lens.set(part, whole) }
}
