//
//  0279_PerfectSquares.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/6/2.
//

import Foundation

/*
 给你一个整数 n ，返回 和为 n 的完全平方数的最少数量 。
 完全平方数:是一个整数，其值等于另一个整数的平方；换句话说，其值等于一个整数自乘的积。例如，1、4、9 和 16 都是完全平方数，而 3 和 11 不是。
 示例 1： 输入：n = 12 输出：3
 解释：12 = 4 + 4 + 4
 示例 2： 输入：n = 13 输出：2 解释：13 = 4 + 9
 */

public class PerfectSquares {
    public class func numSquares(_ n: Int) -> Int {
        // 确定dp[j]含义 最少dp[j]个整数平方和为j
        // 递推公式 dp[j] = min( dp[j - i*i],dp[j])
        // 初始化dp dp[0] = 0 dp[1] = 1
        // 遍历顺序
        print(type(of: self),#function)
        
        guard n >= 1 else { return 1}
        
        var dp: [Int] = [Int](repeating: n, count: n + 1)
        dp[0] = 0
        for j in 1 ... n {
            for i in 0 ..< j {
                if j - i * i >= 0 {
                    //print("dp[",j,"]","+=dp[",j ,"-", i,"*",i,"]")
                    print(dp,"-------dp[",j,"]","=dp[",j ,"-", i,"*",i,"],", "dp[",j,"]")
                    dp[j] = min( dp[j - i*i] + 1,dp[j])
                    print("dp["+"\(j)"+"]=",dp[j])
                }
                
            }
        }
        return dp[n]
    }
}
