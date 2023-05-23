//
//  0416_PartitionEqualSubsetSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/16.
//

import Foundation

public class PartitionEqualSubsetSum {
    public class func canPartition(_ nums: [Int]) -> Bool {
        var sum = 0
        for i in 0 ..< nums.count {
            let num = nums[i]
            sum += num
        }
        
        // 和为奇数，不可能划分成两个和相同的数组
        if sum % 2 != 0 {
            return false
        }
        
        let count = nums.count
        sum /= 2
        
        var dp = [Bool](repeating: false, count: sum + 1)
        dp[0] = true
        
        /*
         var dp = [Int](repeating: 0, count: sum + 1)
         for(int i = 0; i < n; i++) {
             for(int j = target; j >= nums[i]; j--) {
                 //物品 i 的重量是 nums[i]，其价值也是 nums[i]
                 dp[j] = Math.max(dp[j], dp[j-nums[i]] + nums[i]);
             }
         }
         
         */
        
        for i in 0 ..< count {
            for j in (0 ..< dp.count).reversed() {
                if j - nums[i] >= 0 {
                    print("dp", j, " == ", dp[j], "dp", j, "-" , nums[i], " == ", dp[j - nums[i]])
                    dp[j] = dp[j] || dp[j - nums[i]]
                    print("dp", j, " == ", dp[j])
                }
            }
        }
        return dp[sum]
    }
    
    public class func canPartition2(_ nums: [Int]) -> Bool {
        // dp[target] = target target = sum / 2
        // 确定dp[j]含义 dp[j] = 背包容量是j，放进物品后背的最大重量是dp[j]
        // 确定递推公式
        // 初始化
        // 遍历
        
        var sum:Int = 0
        _ = nums.map { num in
            sum += num
        }
        
        if sum % 2 != 0 {
            return false
        }
        
        sum /= 2
        
        var dp: [Int] = [Int](repeating: 0, count: sum)
        
        for _ in 0 ..< nums.count {
            for j in (0 ..< dp.count).reversed() {
                if dp[j] < dp[j - nums[j]] + nums[j] {
                    dp[j] = max(dp[j], dp[j - nums[j]] + nums[j])
                }
            }
        }
        
       return dp[sum] == sum
    }
}
