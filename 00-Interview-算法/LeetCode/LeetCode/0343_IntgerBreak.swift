//
//  0343_IntgerBreak.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/21.
//

import Foundation

/*
 给定一个正整数 n ，将其拆分为 k 个 正整数 的和（ k >= 2 ），并使这些整数的乘积最大化。
 返回 你可以获得的最大乘积 。
 示例 1:
 输入: n = 2 输出: 1
 解释: 2 = 1 + 1, 1 × 1 = 1。
 示例 2:
 输入: n = 10 输出: 36
 解释: 10 = 3 + 3 + 4, 3 × 3 × 4 = 36。

 */

public class IntgerBreak {
    public class func integerBreak(_ n: Int) -> Int {
        // 1.确定dp[i]的含义        dp[i] = 数字i可以获得的最大乘积
        // 2.确定递推公式           dp[i] = dp[i - j] * j  , dp[i] = (i - j) * j
        // 3.数组如何初始化          dp[0][0] = 1
        // 4.遍历循序
        // 5.打印数组
        var dp: [Int] = [Int](repeating: 1, count: n + 1)
        dp[2] = 1
        for i in 3 ... n {
            for j in 1 ..< i - 1 {
                dp[i] = max(dp[i], max((i - j) * j, dp[i - j] * j))
                print(dp[i])
            }
        }
        return dp[n]
    }
}
