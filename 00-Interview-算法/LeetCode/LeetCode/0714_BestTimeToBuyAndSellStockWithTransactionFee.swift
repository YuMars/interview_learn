//
//  0714_BestTimeToBuyAndSellStockWithTransactionFee.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/11.
//

import Foundation

/*
 给定一个整数数组prices，其中prices[i]表示第i天的股票价格；
 整数fee代表了交易股票的手续费用。
 你可以无限次地完成交易，但是你每笔交易都需要付手续费。如果你已经购买了一个股票，在卖出它之前你就不能再继续购买股票了。
 返回获得利润的最大值。
 注意：这里的一笔交易指买入持有并卖出股票的整个过程，每笔交易你只需要为支付一次手续费。
 示例 1：
 输入：prices = [1, 3, 2, 8, 4, 9], fee = 2 输出：8
 解释：能够达到的最大利润:
 在此处买入 prices[0] = 1
 在此处卖出 prices[3] = 8
 在此处买入 prices[4] = 4
 在此处卖出 prices[5] = 9
 总利润: ((8 - 1) - 2) + ((9 - 4) - 2) = 8
 示例 2：
 输入：prices = [1,3,7,5,10,3], fee = 3
 输出：6
 */

public class BestTimeToBuyAndSellStockWithTransactionFee {
    public class func maxProfit(_ prices: [Int], _ fee: Int) -> Int {
        guard prices.count > 1 else { return 0}
        
        var base: Int = prices[0] + fee; // 初始需要的花费
        var profit: Int = 0; // 收益
        
        for i in 1 ..< prices.count {
            if prices[i] > base { // 利润
                profit += prices[i] - base
                base = prices[i]
            } else if prices[i] < base - fee { // 当前价格<成本（=上一次价格+手续费）-手续费
                base = prices[i] + fee // 不断试探选择下一个价格最低点
            }
        }
        
        return profit;
    }
}
