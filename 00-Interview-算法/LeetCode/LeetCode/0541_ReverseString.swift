//
//  0541_ReverseString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/21.
//

import Foundation

public class ReverseString2 {
    
    // 正常思路
    public class func reverseStr(_ s: String, _ k: Int) -> String {
        var array = Array(s)
        var left = 0
        
        
        while left < s.count {
            let right = left + k - 1
            
            if right < s.count { // 字符串还足够长，也就是剩余字符大于k
                reverse(&array, left, right)
            } else { // 不足k个字符，反转剩余所有的
                reverse(&array, left, s.count - 1)
            }
            
            
            left += 2 * k
        }
        
        return String(array)
    }
    
    private class func reverse(_ arrayS: inout [Character], _ left: Int, _ right: Int) {
        
        var l = left
        var r = right
        while l < r {
            let temp = arrayS[l]
            arrayS[l] = arrayS[r]
            arrayS[r] = temp
            
            l += 1
            r -= 1
        }
    }
}
