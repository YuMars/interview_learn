//
//  0151_ReverseWordsinAString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/25.
//

import Foundation

public class ReverseWordsInAString {
    public class func reverseWords(_ s: String) -> String {
        // 1.移除前后空格
        var stringArray = removeSpace(s)
        // 2.反转整个字符串
        reverseString(&stringArray, 0, stringArray.count - 1)
        // 3.反转单词
        reverseWord(&stringArray)
        return String(stringArray)
    }
    
    class func removeSpace(_ s: String) -> [Character] {
        let string = Array(s)
        var left = 0
        var right = string.count - 1
        while string[left] == " " { // 去掉头部空格
            left += 1
        }
        
        while string[right] == " " {// 去掉尾部空格
            right -= 1
        }
        
        var lastArr = Array<Character>()
        while left <= right {
            let char = string[left]
            if char != " " || lastArr[lastArr.count - 1] != " " { // 连续加入的不为空格
                lastArr.append(char)
            }
            left += 1
        }
        return lastArr
    }
    
    class func reverseString(_ s: inout [Character], _ startIndex: Int, _ endIndex: Int) {
        var left = startIndex
        var right = endIndex
        while left < right {
            (s[left], s[right]) = (s[right], s[left])
            left += 1
            right -= 1
        }
    }
    
    class func reverseWord(_ s: inout [Character]) {
        var left = 0
        var right = 0
        var entry = false
        
        for i in 0 ..< s.count {
            if entry == false {
                left = i
                entry = true
            }
            
            if entry && s[i] == " " && s[i - 1] != " " {
                right = i - 1
                entry = false
                reverseString(&s, left, right)
            }
            
            if entry && (i == s.count - 1) && s[i] != " " {
                right = i
                entry = false
                reverseString(&s, left, right)
            }
        }
    }
}
