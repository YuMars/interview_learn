//
//  0150_EvaluateReversePolishNotation.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/28.
//

import Foundation

public class EvaluateReversePolishNotation {
    public class func evalRPN(_ tokens: [String]) -> Int {
        var stack = [Int]()
        for char in tokens {
            if let num = Int(char) {
                stack.append(num)
            } else {
                var res: Int = 0
                let num1 = stack.popLast()!
                let num2 = stack.popLast()!
                switch char {
                case "+": res = num2 + num1
                case "-": res = num2 - num1
                case "*": res = num2 * num1
                case "/": res = num2 / num1
                default: break
                }
                
                stack.append(res)
            }
        }
        return stack.last!
    }
}
