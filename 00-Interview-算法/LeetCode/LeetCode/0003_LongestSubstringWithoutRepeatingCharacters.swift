//
//  0003_LongestSubstringWithoutRepeatingCharacters.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/10.
//

import Foundation

/*
 给定一个字符串 s ，请你找出其中不含有重复字符的最长子串的长度。

 */

public class LongestSubstringWithoutRepeatingCharacters {
    
    /// 滑动窗口解法
    /// 窗口从头开始向右滑动，用hashmap记录，没有重复出现的数字则一直向右滑动，出现重复的字符后记录保存最大值
    /// 出现重复的字符后从左边重复的字符移出
    public class func lengthOfLongestSubstring(_ s: String) -> Int {
        // akhjkbcabcbb
        if s.count < 2 {  return s.count }
        let charArray = Array<Character>(s)
        var map = [Character: Int]()
        var maxLenth = 0
        var start = 0 // 窗口左边
        for i in 0..<charArray.count {
            let char = charArray[i]
            print(i,char)
            if let preIndex = map[char] { // hashmap里面已经记录该字符
                print("重复 - start = max(start:\(start), index+1:\(preIndex + 1)) = " ,max(start, preIndex + 1) )
                start = max(start, preIndex + 1)   //"abba"的情况, 所以用max()
            }
            print("maxLenth = max(maxLenth:\(maxLenth), i - start + 1:\(i - start + 1)) = " ,max(maxLenth, i - start + 1) )
            maxLenth = max(maxLenth, i - start + 1)
            map[char] = i
            print(map)
            //print("\(chs[0...i])的最长无重复子串长度是\(maxLen), start=\(start)")
        }
        return maxLenth
    }
    
    public class func lengthOfLongestSubstring2(_ s: String) -> Int {
        let charArray: Array = Array(s)
        var left: Int = 0
        var maxLength: Int = 0
        var map: [Character : Int] = [Character : Int]()
        for i in 0..<charArray.count {
            let char = charArray[i]
            
            if let preIndex = map[char] { // 如果hashmap里面已经记录了char这个字符，就把滑动窗口的左边往右移
                left = max(left, preIndex + 1)
            }
            
            map[char] = i // 记录当前字符出现新的位置
            maxLength = max(maxLength, i - left + 1) // 计算无重复字符串的最大长度
        }
        return maxLength
    }
    
    // 暴力解法
    public class func lengthOfLongestSubstring1(_ s: String) -> Int {
        
        guard s.count > 1 else { return s.count}
        var maxSubString: Int = 0
        for i in 0..<s.count {
            
            var set: Set = Set<Character>()
            set.insert(s[s.index(s.startIndex, offsetBy: i)])
//            print(set)
            var containsSameChar: Bool = false
            for j in i+1..<s.count {
                let char = s[s.index(s.startIndex, offsetBy: j)]
//                print("char:", char)
                if set.contains(char) {
                    maxSubString = max(j - i, maxSubString)
                    containsSameChar = true
                    break
                } else {
                    set.insert(char)
                }
            }
            
            if containsSameChar ==  false {
                maxSubString = max(s.count - i, maxSubString)
            }
        }
        
        return maxSubString
    }
}
