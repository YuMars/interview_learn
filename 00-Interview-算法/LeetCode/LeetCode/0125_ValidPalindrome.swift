//
//  0125_ValidPalindrome.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/13.
//

import Foundation
/*
 如果在将所有大写字符转换为小写字符、并移除所有非字母数字字符之后，短语正着读和反着读都一样。则可以认为该短语是一个 回文串 。

 字母和数字都属于字母数字字符。

 给你一个字符串 s，如果它是 回文串 ，返回 true ；否则，返回 false 。
 */

public class ValidPalindrome {
    public class func isPalindrome(_ s: String) -> Bool {
        
        let s = s.lowercased()
        if s.count == 0 || s.count == 1 { return true}
        let arr = Array(s)
        var left: Int = 0
        var right = s.count - 1
        while left <= right {
            
            if !arr[left].isLetter && !arr[left].isNumber {
                left += 1
                continue
            }
            
            if !arr[right].isLetter && !arr[right].isNumber {
                right -= 1
                continue
            }
            
            if arr[left] != arr[right] {
                return false
            }
            
            left += 1
            right -= 1
        }
        
        return true
    }
}
