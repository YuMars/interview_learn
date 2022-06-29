//
//  0209_MinimumSizeSubarraySum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/6/28.
//

import Foundation

class MinimumSizeSubarraySum {
    
    /// 暴力解法
    public class func minSubArrayLen(_ target: Int, _ nums: [Int]) -> Int {
        var count = -1
        for i in 0 ..< nums.count {
            
            var total: Int = 0
            for j in i ..< nums.count {
                total += nums[j]
                if total >= target {
                    if count > j - i + 1 || count < 0 {
                        count = j - i + 1
                        break
                    }
                }
            }
            
        }
        return count == -1 ? 0 : count
    }
    
    /// 滑动窗口
    public class func minSubArrayLen1(_ target: Int, _ nums: [Int]) -> Int {
        var length = -1
        var left: Int = 0
        var sum: Int = 0
        for i in 0 ..< nums.count {
            
            sum += nums[i]
            while sum >= target {
                let result = i - left + 1
//                if length == -1 {
//                    length = result
//                } else if length > result {
//                    length = result
//                }
                
                length = length == -1 ? result : (length > result ? result : length)
                sum -= nums[left]
                left += 1
                
            }
            
        }
        return length == -1 ? 0 : length
    }
}
