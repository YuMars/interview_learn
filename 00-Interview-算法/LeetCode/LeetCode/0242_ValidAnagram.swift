//
//  0242_ValidAnagram.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/13.
//

import Foundation

public class ValidAnagram {
    
    /// 排序法
    public class func isAnagram(_ s: String, _ t: String) -> Bool {
        
        if s.count != t.count { return false }
        
        let RS: Array = s.sorted()
        let RT: Array = t.sorted()
        
        for index in 0 ..< s.count {
            if RS[index] != RT[index] {
                return false
            }
        }
        
        return true
    }
    
    /// 删除法
    public class func isAnagram2(_ s: String, _ t: String) -> Bool {
        
        if s.count != t.count { return false }
        
        var RT: Array = Array(t)
        
        for sIndex in 0 ..< s.count {
            
            for i in 0 ..< RT.count {
                if s[s.index(s.startIndex, offsetBy: sIndex)] == RT[i] {
                    RT.remove(at: i)
                    break
                }
            }
        }
        
        return RT.count == 0 ? true : false
    }
    
    /// 哈希方法
    public class func isAnagram3(_ s: String, _ t: String) -> Bool {
        
        if s.count != t.count { return false }
        
        var record = Array(repeating: 0, count: 26)
        let aUnicode = "a".unicodeScalars.first!.value
        
        for sChar in s.unicodeScalars {
            record[Int(sChar.value - aUnicode)] += 1
        }
        
        for tChar in t.unicodeScalars {
            record[Int(tChar.value - aUnicode)] -= 1
        }
        
        for value in record {
            if value != 0 {
                return false
            }
        }
        
        return true
    }
}
