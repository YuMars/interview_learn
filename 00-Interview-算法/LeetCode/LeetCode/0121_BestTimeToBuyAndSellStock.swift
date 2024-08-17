//
//  0121_BestTimeToBuyAndSellStock.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/12.
//

import Foundation

/*
 给定一个数组 prices ，它的第 i 个元素 prices[i] 表示一支给定股票第 i 天的价格。
 你只能选择 某一天 买入这只股票，并选择在 未来的某一个不同的日子 卖出该股票。设计一个算法来计算你所能获取的最大利润。
 返回你可以从这笔交易中获取的最大利润。如果你不能获取任何利润，返回 0 .
 示例 1：
 输入：[7,1,5,3,6,4] 输出：5
 解释：在第 2 天（股票价格 = 1）的时候买入，在第 5 天（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。
      注意利润不能是 7-1 = 6, 因为卖出价格需要大于买入价格；同时，你不能在买入前卖出股票。
 示例 2
 输入：prices = [7,6,4,3,1] 输出：0
 解释：在这种情况下, 没有交易完成, 所以最大利润为 0。
 */

public class BestTimeToBuyAndSellStock {
    public class func maxProfit(_ prices: [Int]) -> Int {
        var minV: Int = Int.max
        var result = 0
        for i in 0 ..< prices.count {
            minV = min(minV, prices[i])
            result = max(prices[i] - minV, result)
        }
        return result
    }
    
    // 解法一：暴力解法
    public class func maxProfit1(_ prices: [Int]) -> Int {
        var minPrice: Int = Int.max
        var result: Int = 0
        for i in 0..<prices.count {
            minPrice = min(minPrice, prices[i])
            result = max(prices[i] - minPrice, result)
        }
        
        return result
    }
    
    // 解法二：动态规划解法
    public class func maxProfit2(_ prices: [Int]) -> Int {
        guard prices.count > 0 else {return 0}
        var minPrice: Int = prices[0]
        var dp:[Int] = [Int](repeating: 0, count: prices.count) // dp[i]表示 第i天的最大利润 dp[i] = max(dp[i - 1], prices[i] - minprices)
        dp[0] = 0
        for i in 1..<prices.count {
            minPrice = min(minPrice, prices[i])
            dp[i] = max(dp[i - 1], prices[i] - minPrice)
        }
        
        return dp[prices.count - 1]
    }
}
