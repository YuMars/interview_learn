//
//  0344_ReverseString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/21.
//

import Foundation

public class ReverseString {
    public class func reverseString(_ s: inout [Character]) {
        var left: Int = 0
        var right: Int = s.count - 1
        
        while left < right {
            let temp = s[left]
            s[left] = s[right]
            s[right] = temp
            
            left += 1
            right -= 1
        }
    }
    
    // 元组
    public class func reverseString2(_ s: inout [Character]) {
        var left: Int = 0
        var right: Int = s.count - 1
        
        while left < right {
            (s[left], s[right]) = (s[right], s[left])
            
            left += 1
            right -= 1
        }
    }
}
