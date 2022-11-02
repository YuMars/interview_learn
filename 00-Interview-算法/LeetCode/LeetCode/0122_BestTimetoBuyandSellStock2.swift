//
//  0122_BestTimetoBuyandSellStock2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/31.
//

import Foundation

public class BestTimetoBuyandSellStock2 {
    public class func maxProfit(_ prices: [Int]) -> Int {
        var result = 0
        for i in 1 ..< prices.count {
            let value = prices[i] - prices[i - 1]
            result = value > 0 ? result + value : result
        }
        return result
    }
}
