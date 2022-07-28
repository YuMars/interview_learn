//
//  0020_ValidParentheses.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/27.
//

import Foundation

public class ValidParentheses {
    public class func isValid(_ s: String) -> Bool {
        var array = [String.Element]()
        
        for (_, char) in s.enumerated() {
            if char == "(" {
                array.append(")")
            } else if char == "[" {
                array.append("]")
            } else if char == "{" {
                array.append("}")
            } else if array.isEmpty {
                return false
            } else if char != array.last  {
                 return false
            } else {
                array.removeLast()
            }
        }
        
        return array.isEmpty
    }
}
