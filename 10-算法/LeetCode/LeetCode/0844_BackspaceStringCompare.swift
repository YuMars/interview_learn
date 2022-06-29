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
    
    // 双指针方法 (两个字符串s、t，分别从字符串尾部开始遍历判断对应的字符串是否相同，如果遇到#，标记遇到#的次数再往前偏移对应的次数，再做两个字符串的比较)
    public class func backspaceCompare2(_ s: String, _ t: String) -> Bool {
        var sIndex = s.count - 1
        var tIndex = t.count - 1
        var sJump: Int = 0
        var tJump: Int = 0
        
        while sIndex >= 0 || tIndex >= 0 {
            while (sIndex >= 0) {
                if s[s.index(s.startIndex, offsetBy: sIndex)] == "#" {
                    sJump += 1
                    sIndex -= 1
                } else if sJump > 0 {
                    sJump -= 1
                    sIndex -= 1
                } else {
                    break
                }
            }
            
            while tIndex >= 0 {
                if t[t.index(t.startIndex, offsetBy: tIndex)] == "#" {
                    tJump += 1
                    tIndex -= 1
                } else if tJump > 0 {
                    tJump -= 1
                    tIndex -= 1
                } else {
                    break
                }
            }
            
            if sIndex >= 0, tIndex >= 0 {
                if s[s.index(s.startIndex, offsetBy: sIndex)] != t[t.index(t.startIndex, offsetBy: tIndex)] {
                    return false
                }
            } else {
                if sIndex >= 0 || tIndex >= 0 {
                    return false
                }
            }
            
            sIndex -= 1
            tIndex -= 1
        }
        return true
    }
}
