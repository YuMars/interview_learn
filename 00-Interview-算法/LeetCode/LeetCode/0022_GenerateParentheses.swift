//
//  0022_GenerateParentheses.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/15.
//

import Foundation

/*
 数字n代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且有效的 括号组合。
 */
public class GenerateParentheses {
    public class func generateParenthesis(_ n: Int) -> [String] {
        guard n > 0 else { return []}
        
        var resultArray:[String] = [String]()
        var string: String = ""
        backtrack(n, n, &string, &resultArray)
        
        return resultArray
    }
    
    /// left表示左括号剩余数量，right表示右括号剩余数量
    class func backtrack(_ left: Int, _ right: Int, _ string: inout String, _ resultArray: inout [String]) {
        
        if left > right { return } // 右括号剩余数量要大于等于左括号
        if left < 0 || right < 0 { return }
        
        if left == 0 && right == 0 {
            resultArray.append(string)
            return
        }
        
        
        
        // 左括号减一
        string = string.appending("(")
        backtrack(left - 1, right, &string, &resultArray)
        string.remove(at: string.index(before: string.endIndex))
        
        // 右括号减一
        string = string.appending(")")
        backtrack(left, right - 1, &string, &resultArray)
        string.remove(at: string.index(before: string.endIndex))
    }
}
