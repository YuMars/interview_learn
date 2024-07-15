//
//  0020_ValidParentheses.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/27.
//

import Foundation

/*
 给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串 s，判断字符串是否有效。
 有效字符串需满足：
 1.左括号必须用相同类型的右括号闭合。
 2.左括号必须以正确的顺序闭合。
 3.每个右括号都有一个对应的相同类型的左括号。
 */

public class ValidParentheses {
    
    /// 栈解法
    public class func isValid1(_ s: String) -> Bool {
        let sArray:[Character] = Array(s)
        var queue:[Character] = [Character]()
        for (_, char) in sArray.enumerated() {
            if char == "(" {
                queue.append(")")
            } else if char == "{" {
                queue.append("}")
            } else if char == "[" {
                queue.append("]")
            } else if queue.isEmpty {
                return false
            } else if char != queue.last {
                return false
            } else { // 如果是 char == queue.last 移除加入的占位
                queue.removeLast()
            }
        }
        
        return queue.isEmpty
        
    }
    
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
