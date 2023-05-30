//
//  377_CombinationSum4.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/30.
//

import Foundation

/*
 给你一个由不同整数组成的数组nums，和一个目标整数target。请你从nums中找出并返回总和为target的元素组合的个数。题目数据保证答案符合32位整数范围。
 示例 1： 输入：nums = [1,2,3], target = 4 输出：7
 解释：
 所有可能的组合为：
 (1, 1, 1, 1)
 (1, 1, 2)
 (1, 2, 1)
 (1, 3)
 (2, 1, 1)
 (2, 2)
 (3, 1)
 请注意，顺序不同的序列被视作不同的组合。
 示例 2： 输入：nums = [9], target = 3 输出：0
 */

public class CombinationSum4 {
    public class func combinationSum4(_ nums: [Int], _ target: Int) -> Int {
        // 确定dp[j]的含义，装满背包容量为j的背包，有dp[j]种方式
        // 递推公式dp[j] += dp[j - num[i]] + 1
        var dp = Array(repeating: 0, count: target + 1)
        dp[0] = 1
        
        for i in 1...target {
            for num in nums {
                if i >= num {
                    print("dp[" + "\(i)" + "] +=" + "dp[" + "\(i)" + "-" + "\(num)" + "]")
                    dp[i] += dp[i - num]
                    
                }
            }
        }
        
        return dp[target]
    }
    
    public class func combinationSum4_2(_ nums: [Int], _ target: Int) -> Int {
        
        // 确定dp[i][j]的含义 从前i个元素中选择，何为j的组合数
        // 递推公式1 dp[i][i] = 选num[i]这个元素的组合+前i-1个元素和为j：(dp[i - 1][j - num[i]])的组合数 +
        //                    不选num[i]这个元素的组合+前i个元素和为j:dp[i - 1][j]的组合数
        //
        // 初始化dp[i][0] = 1
        // 遍历
        
        if target == 0 { return 1 }
        
        var dp: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: target + 1), count: nums.count)
        
        for i in 0 ..< nums.count {
            dp[i][0] = 1
        }
        
        for j in 1 ... target {
            for i in 0 ..< nums.count {
                let num = nums[i]
                if num <= j {
                    dp[i][j] &+= dp[i][j - num] // 选择num[i]
                }
                
                if i > 0 {
                    dp[i][j] &+= dp[i - 1][j] // 不选择num[i]
                }
            }
        }
        return dp[nums.count - 1][target]
    }
}
