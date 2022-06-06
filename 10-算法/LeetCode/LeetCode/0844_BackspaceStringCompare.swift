//
//  0844_BackspaceStringCompare.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/6/2.
//

import Foundation

class BackspaceStringCompare {
    
    // 重构字符串
    public class func backspaceCompare(_ s: String, _ t: String) -> Bool {
        return rebuilt(s) == rebuilt(t)
    }
    
    private class func rebuilt(_ string: String) -> String {
        var string1 = String()
        for str in string {
            if str != "#" {
                string1.append(str)
            } else {
                if string1.count > 0 {
                    string1.removeLast()
                }
            }
        }
        return string1
    }
    
    // 双指针方法
    public class func backspaceCompare2(_ s: String, _ t: String) -> Bool {
        var sIndex = s.count - 1
        var tIndex = t.count - 1
        var sJump: Int = 0
        var tJump: Int = 0
        
        while sIndex >= 0 || tIndex >= 0 {
            if (sIndex >= 0) {
                if s[s.index(s.startIndex, offsetBy: sIndex)] == "#" {
                    sJump += 1
                }
                sIndex -= 1
            }
        }
    }
}
