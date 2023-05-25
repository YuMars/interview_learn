//
//  0494_TargetSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/24.
//

import Foundation

/*
 给你一个整数数组 nums 和一个整数 target 。

 向数组中的每个整数前添加 '+' 或 '-' ，然后串联起所有整数，可以构造一个 表达式 ：

 例如，nums = [2, 1] ，可以在 2 之前添加 '+' ，在 1 之前添加 '-' ，然后串联起来得到表达式 "+2-1" 。
 返回可以通过上述方法构造的、运算结果等于 target 的不同 表达式 的数目。
 */

public class TargetSum {
    public class func findTargetSumWays(_ nums: [Int], _ target: Int) -> Int {
        // 确定dp[j]含义 dp[j] = 装满背包容量位j的背包有dp[j]种方法
        // 确定递推公式 dp[j] += dp[j - num[i]]
        
        var sum: Int = 0
        _ = nums.map({ sum += $0 })
        
        // left:[Int] + right:[Int] = sum
        // left:[Int] - right:[Int] = target
        // right:[Int] + right:[Int] = sum + target
        // right:[Int] = (sum + target) / 2
        
        if abs(target) > sum { return 0 }
        if (sum + target) % 2 == 1 {return 0}
        
        let bagSize = (sum + target) / 2
        var dp: [Int] = [Int](repeating: 0, count: bagSize + 1)
        dp[0] = 1
        for i in 0 ..< nums.count { // 遍历物品
            
            if bagSize >= nums[i] { // 背包大小比num[i]大
                for j in (nums[i] ... bagSize).reversed() { // 倒序遍历
                    dp[j] += dp[j - nums[i]]
                }
            }
        }
        return dp[bagSize]
    }
}
