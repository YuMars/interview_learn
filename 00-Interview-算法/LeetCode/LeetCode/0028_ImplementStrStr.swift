//
//  0028_ImplementStrStr.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/26.
//

import Foundation

public class ImplementStrStr {
    public class func strStr(_ haystack: String, _ needle: String) -> Int {
        let s = Array(haystack)
        let p = Array(needle)
        guard p.count != 0 else { return 0}
        
        var j = 0
        var next = [Int](repeating: 0, count: needle.count)
        
        // KMP
        getNext(next: &next, needle: p)
        
        for i in 0 ..< s.count {
            while j > 0 && s[i] != p[j] { // 如果出现匹配最长匹配前缀，查找下一个
                j = next[j - 1]
            }
            
            if s[i] == p[j] { // 匹配字段
                j += 1
            }
            
            if j == p.count { // 看看匹配结束了没
                return i - p.count + 1
            }
        }
        return -1
    }
    
    public class func getNext( next: inout [Int],  needle: [Character]) {
        var j = 0
        next[0] = j
        
        for i in 1 ..< needle.count {
            while j > 0 && needle[i] != needle[j] {
                j = next[j - 1]
            }
            
            if needle[i] == needle[j] {
                j += 1
            }
            
            next[i] = j
        }
    }
}
