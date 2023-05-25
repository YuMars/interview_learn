//
//  1049_LastStoneWeight2.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/24.
//

import Foundation

public class LastStoneWeight2 {
    public class func lastStoneWeightII(_ stones: [Int]) -> Int {
        
        var sum:Int = 0
        _ = stones.map { num in
            sum += num
        }
        
        let target = sum / 2
        
        var dp: [Int] = [Int](repeating: 0, count: target + 1)
        
        dp[0] = 0
        
        for i in 0 ..< stones.count { // 遍历物品
            if stones[i] <= target {
                for j in (stones[i] ... target).reversed() { // 遍历
                    print(j)
                    dp[j] = max(dp[j], dp[j - stones[i]] + stones[i])
                }
            }
        }
        return sum - dp[target] - dp[target]
    }
}
