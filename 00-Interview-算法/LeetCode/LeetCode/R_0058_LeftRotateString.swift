//
//  R_0058_LeftRotateString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/26.
//

import Foundation

public class LeftRotateString {
    public class func reverseLeftWords(_ s: String, _ n: Int) -> String {
        
        // 1.反转0-n
        var arrString = Array(s)
        
        // 2.反转n-s.count-1
        reverseWord(&arrString, 0, n - 1)
        reverseWord(&arrString, n, s.count - 1)
        // 3.全部反转
        reverseWord(&arrString, 0, s.count - 1)
        
        return String(arrString)
    }
    
    public class func reverseWord(_ s: inout [Character], _ startIndex: Int, _ endIndex: Int) {
        var left = startIndex
        var right = endIndex
        while left < right {
            (s[left], s[right]) = (s[right], s[left])
            left += 1
            right -= 1
        }
    }
}
