//
//  0763_PartitionLabels.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/9.
//

import Foundation
/*
 字符串S由小写字母组成。我们要把这个字符串划分为尽可能多的片段，同一字母最多出现在一个片段中。返回一个表示每个字符串片段的长度的列表。
 示例：
 输入：S = "ababcbacadefegdehijhklij" 输出：[9,7,8]
 解释：
 划分结果为 "ababcbaca", "defegde", "hijhklij"。
 每个字母最多出现在一个片段中。
 像 "ababcbacadefegde", "hijhklij" 的划分是错误的，因为划分的片段数较少。
 */

public class PartitionLabels {
    public class func partitionLabels(_ s: String) -> [Int] {
        var result = [Int]()
        
        var charArray = [Int](repeating: 0, count: 26)
        let s = Array(s)
        for i in 0 ..< s.count {
            charArray[Int(Int8(s[i].asciiValue!) - Int8(("a" as Character).asciiValue!))] = i
        }
        
        var index: Int = 0
        var lastIndex: Int = -1
        for i in 0 ..< s.count {
            index = max(index, charArray[Int(Int8(s[i].asciiValue!) - Int8(("a" as Character).asciiValue!))])
            if index == i {
                result.append(i - lastIndex)
                lastIndex = i
            }
        }
        return result
    }
}
