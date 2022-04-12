//
//  0035_SearchInsertPosition.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/29.
//

import Foundation
// target = 5
// 1, 2, 3, 4, 6, 7, 8
// 0  1  2  3  4  5  6
class SearchInsertPosition {
    
    public class func searchInsert(_ nums: [Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count
        
        while left <= right {
            let middle = left + (right - left) / 2
            if nums[middle] < target {
                left = middle + 1
            } else if nums[middle] > target {
                right = middle - 1
            } else {
                return middle
            }
        }
        return right + 1
    }
    
    // 暴力查询
    public class func searchInsert2(_ nums: [Int], _ target: Int) -> Int {
        for index in 0..<nums.count {
            if nums[index] >= target {
                return index
            }
        }
        return nums.count
    }
    
    // 二分法查询
    public class func searchInsert3(_ nums: [Int], _ target: Int) -> Int {
        // 分别处理如下四种情况
        // 目标值在数组所有元素之前  [0, -1]
        // 目标值等于数组中某一个元素  return middle;
        // 目标值插入数组中的位置 [left, right]，return  right + 1
        // 目标值在数组所有元素之后的情况 [left, right]， return right + 1
        
        var left: Int = 0
        var right: Int = nums.count - 1
        while left <= right {
            let middle = left + (left - right) / 2
            if nums[middle] == target {
                return middle
            } else if nums[middle] > target { // 当前中间值大于目标值
                right = middle - 1
            } else if nums[middle] < target {
                left = middle + 1
            }
        }
        return right + 1
    }
    
    public class func searchInsert4(_ nums: [Int], _ target: Int) -> Int {
        
        // 分别处理如下四种情况
        // 目标值在数组所有元素之前 [0,0)
        // 目标值等于数组中某一个元素 return middle
        // 目标值插入数组中的位置 [left, right) ，return right 即可
        // 目标值在数组所有元素之后的情况 [left, right)，return right 即可
        
        var left: Int = 0
        var right: Int = nums.count
        while left < right {
            let middle = left + (left - right) / 2
            if nums[middle] == target {
                return middle
            } else if nums[middle] > target { // 当前中间值大于目标值
                right = middle
            } else if nums[middle] < target {
                left = middle + 1
            }
        }
        return right
    }
    
}
