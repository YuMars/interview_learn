//
//  0076_MinimumWindowSubstring.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/30.
//

import Foundation

/*
 给你一个字符串s、一个字符串t。返回 s 中涵盖t所有字符的最小子串。如果 s 中不存在涵盖 t所有字符的子串，则返回空字符串 "" 。
 注意：
 
 对于 t 中重复字符，我们寻找的子字符串中该字符数量必须不少于 t 中该字符数量。
 如果 s 中存在这样的子串，我们保证它是唯一的答案。
 */
public class MinimumWindowSubstring {
    
    /// 滑动窗口解法
    public class func minWindow1(_ s: String, _ t: String) -> String {
        let sArr = [Character](s)
        // 窗口的字典
        var windowDict = [Character: Int]()
        // 所需字符的字典
        var needDict = [Character: Int]()
        for c in t {
            needDict[c, default: 0] += 1
        }
        
        // 当前窗口的左右两端
        var left = 0, right = 0
        // 匹配次数，等于needDict的key数量时代表已经匹配完成
        var matchCnt = 0
        // 用来记录最终的取值范围
        var start = 0, end = 0
        // 记录最小范围
        var minLen = Int.max
        
        while right < sArr.count {
            // 开始移动窗口右侧端点
            let rChar = sArr[right]
            right += 1
            // 右端点字符不是所需字符直接跳过
            if needDict[rChar] == nil { continue }
            // 窗口中对应字符数量+1
            windowDict[rChar, default: 0] += 1
            // 窗口中字符数量达到所需数量时，匹配数+1
            if windowDict[rChar] == needDict[rChar] {
                matchCnt += 1
            }
            
            // 如果匹配完成，开始移动窗口左侧断点, 目的是为了寻找当前窗口的最小长度
            while matchCnt == needDict.count {
                // 记录最小范围
                if right - left < minLen {
                    start = left
                    end = right
                    minLen = right - left
                }
                let lChar = sArr[left]
                left += 1
                if needDict[lChar] == nil { continue }
                // 如果当前左端字符的窗口中数量和所需数量相等，则后续移动就不满足匹配了，匹配数-1
                if needDict[lChar] == windowDict[lChar] {
                    matchCnt -= 1
                }
                // 减少窗口字典中对应字符的数量
                windowDict[lChar]! -= 1
            }
        }
        
        return minLen == Int.max ? "" : String(sArr[start..<end])
    }
    
    
    
    
    /// 暴力解法
    public class func minWindow(_ s: String, _ t: String) -> String {
        /// 1.map记录t的字符和个数
        /// 滑动窗口left right。left开始遍历，right往右循环
        
        guard s.count > 0 || t.count > 0 else {return ""}
        
        var charArray:[Int] = [Int](repeating: 0, count: 26)
        
        let sArray:[Character] = Array(s)
        let tArray:[Character] = Array(t)
        
        for i in 0..<tArray.count {
            let index: Int = Int(UInt8((tArray[i].asciiValue! - Character("a").asciiValue!)))
            charArray[index] += 1
        }
        
        var minLeft: Int = 0
        var minRight: Int = Int.max
        
        var left: Int = 0
        var right: Int = sArray.count - 1
        
        while left < sArray.count {
            let index: Int = Int(UInt8((sArray[left].asciiValue! - Character("a").asciiValue!)))
            if charArray[index] == 0 {
                left += 1
                continue
            }
            
            right = left
            var tempCharArray = charArray
            while right < sArray.count {
                let index: Int = Int(UInt8((sArray[right].asciiValue! - Character("a").asciiValue!)))
                if tempCharArray[index] > 0 {
                    tempCharArray[index] -= 1
                    
                    if tempCharArray[index] == 0 {
                        var needStop: Bool = true
                        for i in 0..<tempCharArray.count {
                            if tempCharArray[i] > 0 {
                                needStop = false
                                break
                            }
                        }
                        
                        if needStop {
                            if right - left < minRight - minLeft {
                                minRight = right
                                minLeft = left
                            }
                            
                            break
                        }
                    }
                }
                right += 1
            }
            left += 1
        }
        
        if minRight == Int.max {
            return ""
        }
        
        return String(sArray[minLeft...minRight])
    }
}
