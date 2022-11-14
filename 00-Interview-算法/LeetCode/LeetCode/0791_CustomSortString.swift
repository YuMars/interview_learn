//
//  0791_CustomSortString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/13.
//

import Foundation
/*
 给定两个字符串order和s。order的所有单词都是唯一的，并且以前按照一些自定义的顺序排序。
 对s的字符进行置换，使其与排序的order相匹配。更具体地说，如果在order中的字符x出现字符y之前，那么在排列后的字符串中，x也应该出现在y之前。
 返回 满足这个性质的s的任意排列.
 示例 1:
 输入: order = "cba", s = "abcd" 输出: "cbad"
 解释:
 “a”、“b”、“c”是按顺序出现的，所以“a”、“b”、“c”的顺序应该是“c”、“b”、“a”。
 因为“d”不是按顺序出现的，所以它可以在返回的字符串中的任何位置。“dcba”、“cdba”、“cbda”也是有效的输出。
 示例 2:
 输入: order = "cbafg", s = "abcd" 输出: "cbad"
 */
public class CustomSortString {
    public class func customSortString(_ order: String, _ s: String) -> String {
        var dic: [Character: Int] = [:]
        for (i, c) in order.enumerated() {
            dic[c] = i
        }
        
        let array = s.sorted { (c1, c2) -> Bool in
            let ci1 = dic[c1] ?? order.count
            let ci2 = dic[c2] ?? order.count
            return ci1 < ci2
        }
        return array.reduce("") { (c1, c2) -> String in
            return String(c1) + String(c2)
        }
    }
}
