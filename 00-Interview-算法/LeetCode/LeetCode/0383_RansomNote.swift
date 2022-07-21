//
//  0383_RansomNote.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/20.
//

import Foundation

public class RansomNote {
    
    /// 暴力解法
    public class func canConstruct(_ ransomNote: String, _ magazine: String) -> Bool {
        var tempRansomeNote = ransomNote
        for indexM in 0 ..< magazine.count {
            var deleteCount = 0
            for indexR in 0 ..< tempRansomeNote.count {
                if magazine[magazine.index(magazine.startIndex, offsetBy: indexM)] == tempRansomeNote[tempRansomeNote.index(tempRansomeNote.startIndex, offsetBy: indexR - deleteCount)] {
                    tempRansomeNote.remove(at: tempRansomeNote.index(tempRansomeNote.startIndex, offsetBy: indexR - deleteCount))
                    deleteCount += 1
                    break
                }
            }
        }
        
        if tempRansomeNote.count == 0 {
            return true
        }
        
        return false
    }
    
    /// 哈希解法
    public class func canConstruct2(_ ransomNote: String, _ magazine: String) -> Bool {
        var record = Array(repeating: 0, count: 26)
        let aUnicodeScalarValue = "a".unicodeScalars.first!.value
        for unicode in magazine.unicodeScalars {
            // 通过record 记录 magazine 里各个字符出现的次数
            let idx: Int = Int(unicode.value - aUnicodeScalarValue)
            record[idx] += 1
        }
        
        for unicode in ransomNote.unicodeScalars {
            // 遍历 ransomNote,在record里对应的字符个数做 -- 操作
            let idex: Int = Int(unicode.value - aUnicodeScalarValue)
            record[idex] -= 1
            // 如果小于零说明在magazine没有
            if record[idex] < 0 {
                return false
            }
        }
        
        return true
    }
}
