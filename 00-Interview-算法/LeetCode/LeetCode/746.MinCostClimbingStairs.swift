//
//  746.MinCostClimbingStairs.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/16.
//

import Foundation

/*
 给你一个整数数组cost，其中cost[i]是从楼梯第i个台阶向上爬需要支付的费用。一旦你支付此费用，即可选择向上爬一个或者两个台阶。
 你可以选择从下标为0或下标为1的台阶开始爬楼梯。
 请你计算并返回达到楼梯顶部的最低花费。
 示例 1：
 输入：cost = [10,15,20] 输出：15
 解释：你将从下标为 1 的台阶开始。
 - 支付 15 ，向上爬两个台阶，到达楼梯顶部。
 总花费为 15 。
 示例 2：
 输入：cost = [1,100,1,1,1,100,1,1,100,1] 输出：6
 解释：你将从下标为 0 的台阶开始。
 - 支付 1 ，向上爬两个台阶，到达下标为 2 的台阶。
 - 支付 1 ，向上爬两个台阶，到达下标为 4 的台阶。
 - 支付 1 ，向上爬两个台阶，到达下标为 6 的台阶。
 - 支付 1 ，向上爬一个台阶，到达下标为 7 的台阶。
 - 支付 1 ，向上爬两个台阶，到达下标为 9 的台阶。
 - 支付 1 ，向上爬一个台阶，到达楼梯顶部。
 总花费为 6 。
 */

public class MinCostClimbingStairs {
    public class func minCostClimbingStairs(_ cost: [Int]) -> Int {
        // 1.确定dp[i]的含义     dp[i] = 到第i阶的往上爬的当前最小总花费
        // 2.确定递推公式         dp[i] = min(dp[i-1] + cost[i-1], dp[i-2] + cost[i-2])
        // 3.数组如何初始化       dp[0] = min(cost[0], cost[1])
        // 4.遍历循序
        // 5.打印数组
        
        if cost.count == 0 { return 0 }
        if cost.count == 1 { return cost.first!}
        if cost.count == 2 { return min(cost.first!, cost.last!)}
        
        var dp:[Int] = [Int](repeating: 0, count: cost.count + 1)
        dp[0] = cost[0]
        dp[1] = cost[1]
        for i in 2 ..< cost.count {
            dp[i] = min(dp[i-1] + cost[i], dp[i-2] + cost[i])
            //print("dp" + "\(i)" + "=" + "\(dp[i])")
        }
        return min(dp[cost.count - 1], dp[cost.count - 2])
    }
}
 
