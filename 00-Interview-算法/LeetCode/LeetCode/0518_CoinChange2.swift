//
//  0518_CoinChange2.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/25.
//

import Foundation

public class CoinChange2 {
    public class func change(_ amount: Int, _ coins: [Int]) -> Int {
        // 确定dp[j]的含义 dp[i][j] = i种硬背装满容量j的背包能装dp[i][j]种方式
        // 递推公式 dp[i][j] += dp[i - 1][j - k * coins[i]]
        // 初始化数组 dp[0] = 0
        // 遍历
        
    }
}
