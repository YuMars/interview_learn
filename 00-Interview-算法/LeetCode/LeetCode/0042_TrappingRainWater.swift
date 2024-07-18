//
//  0042_TrappingRainWater.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/18.
//

import Foundation

/*
 给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。
 */

public class TrappingRainWater {
    
    /// 动态规划解法
    /// 在暴力解法的
    public class func trap1(_ height: [Int]) -> Int {
        guard height.count > 2 else { return 0} // 保护边界
        var sum: Int = 0
        var dpLeft: [Int] = Array(repeating: 0, count: height.count)
        var dpRight: [Int] = Array(repeating: 0, count: height.count)
        
        for i in 1..<height.count - 1 {
            dpLeft[i] = max(dpLeft[i - 1], height[i - 1])
        }
        
        for i in (0..<height.count - 1).reversed() {
            dpRight[i] = max(dpRight[i + 1], height[i + 1])
        }
        
        for i in 1..<height.count - 1 {
            let minHeight: Int = min(dpLeft[i], dpRight[i])
            if minHeight > height[i] {
                sum = sum + minHeight - height[i]
            }
        }
        
        return sum
    }
        
    
    /// 暴力解法
    /// 遍历当前高度左右两边的比当前高度大的左、右高度，然后取左、右高度中的最小值和当前高度做比较，就是当前高度能容纳的雨水数量
    /// 时间复杂度O(n²)，空间复杂度O(1)
    public class func trap(_ height: [Int]) -> Int {
        guard height.count > 2 else { return 0}
        var sum: Int = 0
        for i in 1..<height.count - 1 {
            
            var leftSideMax: Int = 0
            var rightSideMax: Int = 0
            
            for j in 0..<i {
                leftSideMax = max(leftSideMax, height[j])
            }
            
            for j in i+1..<height.count {
                rightSideMax = max(rightSideMax, height[j])
            }
            
            let curMin: Int = min(leftSideMax, rightSideMax)
            if curMin > height[i] {
                sum = sum + (curMin - height[i])
            }
        }
        
        return sum
        
    }
}
