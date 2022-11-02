//
//  0053_MaximumSubarray.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/29.
//

import Foundation

/*
 给你一个整数数组 nums ，请你找出一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。
 子数组 是数组中的一个连续部分。
 示例 1：
 输入：nums = [-2,1,-3,4,-1,2,1,-5,4] 输出：6
 解释：连续子数组 [4,-1,2,1] 的和最大，为 6 。
 示例 2：
 输入：nums = [1] 输出：1
 示例 3：
 输入：nums = [5,4,-1,7,8] 输出：23
 */

public class MaximumSubarray {
    
    public class func maxSubArray(_ nums: [Int]) -> Int {
        if nums.count == 0 { return 0 }
        var result = nums[0]
        var sum = 0
        for i in 0 ..< nums.count {
            sum += nums[i]
            result = sum > result ? sum : result
            if sum < 0 {
                sum = 0
            }
        }
        return result
    }
    
    // DP
    public class func maxSubArray3(_ nums: [Int]) -> Int {
        if nums.count == 0 { return 0 }
        var result = nums[0]
        var sum = 0
        for i in 0 ..< nums.count {
            if sum > 0 {
                sum += nums[i]
            } else {
                sum = nums[i]
            }
            result = sum > result ? sum : result
        }
        return result
    }
    
    public class func maxSubArray2(_ nums: [Int]) -> Int {
        var result = Int.min;
        var count = 0;
        for i in 0 ..< nums.count { // 设置起始位置
            count = 0;
            for j in  i ..< nums.count { // 每次从起始位置i开始遍历寻找最大值
                count += nums[j];
                result = count > result ? count : result;
            }
        }
        return result;
    }
}
