//
//  0070_ClimbingStairs.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/15.
//

import Foundation

/*
 假设你正在爬楼梯。需要 n 阶你才能到达楼顶。
 每次你可以爬 1 或 2 个台阶。你有多少种不同的方法可以爬到楼顶呢？
 示例 1：
 输入：n = 2 输出：2
 解释：有两种方法可以爬到楼顶。
 1. 1 阶 + 1 阶
 2. 2 阶
 示例 2：
 输入：n = 3 输出：3
 解释：有三种方法可以爬到楼顶。
 1. 1 阶 + 1 阶 + 1 阶
 2. 1 阶 + 2 阶
 3. 2 阶 + 1 阶
 */

public class ClimbingStairs {
    public class func climbStairs(_ n: Int) -> Int {
        guard n > 2 else { return n }
        var dp:[Int] = [Int](repeating: 0, count: n + 1)
        dp[0] = 1
        dp[1] = 1
        for i in 2 ... n {
            dp[i] = dp[i - 1] + dp[i - 2]
        }
        return dp[n]
    }
    
    public class func climbStairs2(_ n: Int) -> Int {
        // 1.确定dp[i]的含义 dp[i]表示有多少种方式爬到i阶
        // 2.确定递推公式
        // 3.dp数组初始化
        // 4.确定遍历顺序
        // 5.print
        
        guard n > 1 else {return 1}
        
        var dp:[Int] = [Int](repeating: 0, count: n + 1)
        dp[0] = 1
        dp[1] = 1
        for i in 2 ... n {
            dp[i] = dp[i - 1] + dp[i - 2]
        }
        return dp[n]
    }
}
