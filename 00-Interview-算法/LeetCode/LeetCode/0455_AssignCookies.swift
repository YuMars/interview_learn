//
//  0455_AssignCookies.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/27.
//

import Foundation

/*
 假设你是一位很棒的家长，想要给你的孩子们一些小饼干。但是，每个孩子最多只能给一块饼干。

 对每个孩子 i，都有一个胃口值 g[i]，这是能让孩子们满足胃口的饼干的最小尺寸；并且每块饼干 j，都有一个尺寸 s[j] 。如果 s[j] >= g[i]，我们可以将这个饼干 j 分配给孩子 i ，这个孩子会得到满足。你的目标是尽可能满足越多数量的孩子，并输出这个最大数值。
 示例 1:
 输入: g = [1,2,3], s = [1,1]
 输出: 1
 解释:
 你有三个孩子和两块小饼干，3个孩子的胃口值分别是：1,2,3。
 虽然你有两块小饼干，由于他们的尺寸都是1，你只能让胃口值是1的孩子满足。
 所以你应该输出1。
 
 示例 2:
 输入: g = [1,2], s = [1,2,3]
 输出: 2
 解释:
 你有两个孩子和三块小饼干，2个孩子的胃口值分别是1,2。
 你拥有的饼干数量和尺寸都足以让所有孩子满足。
 所以你应该输出2.
 */

public class AssignCookies {
    public class func findContentChildren(_ g: [Int], _ s: [Int]) -> Int {
        let children = g.sorted(by: >)
        let cookies = s.sorted(by: >)
        var index = 0
        var result = 0
        for i in 0 ..< children.count {
            
            if  index >= 0, index < cookies.count, cookies[index] >= children[i] {
                index += 1
                result += 1
            }
        }
        return result
    }
}
