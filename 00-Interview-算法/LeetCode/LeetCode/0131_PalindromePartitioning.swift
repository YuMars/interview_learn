//
//  0131_PalindromePartitioning.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/14.
//

import Foundation

/*
 给定一个字符串 s，将 s 分割成一些子串，使每个子串都是回文串。
 返回 s 所有可能的分割方案。
 示例: 输入: "aab" 输出: [ ["aa","b"], ["a","a","b"] ]
 */

public class PalindromePartitioning {
    
    public class func partition(_ s: String) -> [[String]] {
        // 把字符串转为字符数组以便于通过索引访问和取子串
        let s = Array(s)
        // 使用双指针法判断子串是否回文
        func isPalindrome(start: Int, end: Int) -> Bool {
            var start = start, end = end
            while start < end {
                if s[start] != s[end] { return false }
                start += 1
                end -= 1
            }
            return true
        }

        var result = [[String]]()
        var path = [String]() // 切割方案
        func backtracking(startIndex: Int) {
            // 终止条件，收集结果
            guard startIndex < s.count else {
                result.append(path)
                return
            }

            for i in startIndex ..< s.count {
                // 回文则收集，否则跳过
                print(   "---start:" + "\(startIndex)" + "----i:" + "\(i)")
                guard isPalindrome(start: startIndex, end: i) else { continue }
                let substring = String(s[startIndex ... i])
                path.append(substring) // 处理
                backtracking(startIndex: i + 1) // 寻找下一个起始位置的子串
                if !path.isEmpty { path.removeLast() } // 回溯
            }
        }
        backtracking(startIndex: 0)
        return result
    }
    
    public class func partition2(_ s: String) -> [[String]] {
        // 1.回溯字符串分割所有子串
        // 2.每个结果判断是否是回文
        var path = [String]()
        var result = [[String]]()
        let s = Array(s)
        func backtracking(start: Int) {

            if start == s.count {
                result.append(path)
                return
            }

            let end = s.count
            guard start < end else { return }
            for i in start ..< end {
                //let range = s.index(s.startIndex, offsetBy: start) ..< s.index(s.startIndex, offsetBy: i)

                let substring = String(s[start ... i])
                print("string:" + "\(substring)" +  "\n----i:" + "\(i)" + "---start:" + "\(start)")

                if !ValidPalindrome.isPalindrome(substring) { continue }
                path.append(substring)
                backtracking(start: i + 1)
                if !path.isEmpty {
                    path.removeLast()
                }
            }
        }
        backtracking(start: 0)
        return result
    }
}
