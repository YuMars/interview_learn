//
//  0322_CoinChange.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/6/1.
//

import Foundation

public class CoinChange {
    public class func coinChange(_ coins: [Int], _ amount: Int) -> Int {
        // 确定dp[j]含义 凑足总额为j所需钱币的最少个数为dp[j]
        // 递推公式 dp[j] += dp[j - i]
        // 初始化dp dp[0] = 1
        // 遍历顺序
        
        guard amount > 0 else { return 0}
        
        var dp: [Int] = [Int](repeating: Int.max, count: amount + 1)
        dp[0] = 0
        for j in 1 ... amount {
            for i in 0 ..< coins.count {
                
                if j >= coins[i], dp[j - coins[i]] != Int.max {
                    dp[j] = min(dp[j - coins[i]] + 1, dp[j])
                    print("dp:[",j ,"]=",dp[j])
                }
            }
        }
        
        return (dp[amount] == Int.max)  ? -1 : dp[amount]
    }
}
 
