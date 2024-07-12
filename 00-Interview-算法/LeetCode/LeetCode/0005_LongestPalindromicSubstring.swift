//
//  0005_LongestPalindromicSubstring.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/11.
//

import Foundation

/*
 
 */

public class LongestPalindromicSubstring {
    
    /// 中心拓展算法
    ///  从某个位置i的字符开始往两边拓展，判断是不是回文，如果不是回文当前循环结束，反之则继续判断，直到不是回文
    /// 时间复杂度O(n²)，空间复杂度O(1)
    public class func longestPalindrome(_ s: String) -> String {
        guard s.count > 1 else { return s}
        
        let array: [Character] = Array(s)
        
        var maxLength: Int = 1
        var startIndex: Int = 0
        
        for i in 0..<array.count {
            let length1 = expandSide(array, i, i)
            let length2 = expandSide(array, i, i + 1)
            let length = max(length1, length2)
            
            if length > maxLength {
                maxLength = length
                startIndex = i - (maxLength - 1) / 2
            }
        }
        
        let subS = s[s.index(s.startIndex, offsetBy: startIndex)..<s.index(s.startIndex, offsetBy: startIndex + maxLength)]
        return String(subS)
        
    }
    
    public class func expandSide(_ array: [Character], _ l: Int, _ r: Int) -> Int {
        var left = l
        var right = r
        while (left >= 0 && right < array.count && array[left] == array[right]) {
            left -= 1;
            right += 1;
        }
        return right - left - 1; // 这里做了2步，最终的长度计算应该是right - left + 1，但是上面while循环往外左右各多延伸了一步，所以最终长度计算应该是right-1 - (left + 1) + 1 = right - left - 1
    }
        
    
    /// 动态规划解法
    /// 从字符长度2开始往上增加字符长度，并且从头开始遍历，字符串长度为1的字符是回文，判断left -> left+length-1字符串范围内是不是回文
    /// 时间复杂度O(n²)，空间复杂度O(n²)
    public class func longestPalindrome1(_ s: String) -> String {
        
        guard s.count > 1 else { return s}
        
        let array:[Character] = Array(s)
        var dp:[[Bool]] = Array(repeating: Array(repeating: false, count: s.count), count: s.count)
        
        // dp[i][j] == true 代表从s[i]->s[j]范围内的字符串是回文 false则不是回文
        for i in 0..<array.count {
            dp[i][i] = true // 单个字符串是回文
        }
        
        var start: Int = 0
        var maxLength: Int = 1
        
        for length in 2...array.count { // 字符串长度从2开始遍历
            
            for leftIndex in 0..<array.count { // 从最左边开始遍历
                let rightIndex = leftIndex + length - 1 // dp[leftIndex][rightIndex]
                
                if rightIndex >= array.count { break } // 边界值
                
                if array[leftIndex] != array[rightIndex] {
                    dp[leftIndex][rightIndex] = false
                } else {
                    
                    if rightIndex - leftIndex < 3 { // 中间隔一个字符
                        dp[leftIndex][rightIndex] = true
                    } else {
                        dp[leftIndex][rightIndex] = dp[leftIndex + 1][rightIndex - 1]
                    }
                    
                    if (dp[leftIndex][rightIndex] == true) && (rightIndex - leftIndex + 1 > maxLength) {
                        maxLength = rightIndex - leftIndex + 1
                        start = leftIndex
                    }
                }
            }

        }
        let subS = s[s.index(s.startIndex, offsetBy: start)..<s.index(s.startIndex, offsetBy: start + maxLength)]
        return String(subS)
    }
    
    /// 判断是不是回文
    public class func isPalindrome(_ s: String) -> Bool {
        guard s.count > 1 else { return true }
        var left:Int = 0
        var right: Int = s.count
        let stringArray = Array(s)
        while left < right {
            let charL = stringArray[left]
            let charR = stringArray[right]
            if !charL.isLetter || !charL.isNumber {
                left += 1
            } else if !charR.isLetter || !charR.isNumber {
                right -= 1
            } else {
                if charL != charR {
                    return false
                } else {
                    left += 1
                    right -= 1
                }
            }
        }
        return true
    }
}
