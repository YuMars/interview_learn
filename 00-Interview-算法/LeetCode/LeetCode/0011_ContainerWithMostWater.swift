//
//  0011_ContainerWithMostWater.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/12.
//

import Foundation

public class ContainerWithMostWater {
    
    // 双指针解法
    public class func maxArea(_ height: [Int]) -> Int {
        var left: Int = 0
        var right: Int = height.count - 1
        var result: Int = 0
        while left < right {
            let area = min(height[left], height[right]) * (right - left)
            result = max(result, area)
            if height[left] < height[right] {
                left += 1
            } else {
                right -= 1
            }
        }
        return result
    }
}
