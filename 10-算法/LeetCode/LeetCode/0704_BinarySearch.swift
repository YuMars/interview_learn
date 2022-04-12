//
//  0704_BinarySearch.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/28.
//

import Foundation

class BinarySearch {
    public class func search(_ nums: [Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count - 1
        while left <= right {
            let middle = left + (right - left) / 2
            if nums[middle] > target {
                right = middle - 1
            } else if (nums[middle] < target) {
                left = middle + 1
            } else {
                return middle
            }
        }
        return -1;
    }
    
    public class func search2(_ nums: [Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count
        
        while left < right {
            let middle = left + (right - left) / 2
            if target < nums[middle] {
                right = middle
            } else if target > nums[middle] {
                left = middle + 1
            } else {
                return middle
            }
        }
        
        return -1
    }
    
    /// 暴力查询
    public class func search3(_ nums: [Int], _ target: Int) -> Int {
        for index in 0..<nums.count {
            if nums[index] == target {
                return index
            }
        }
        return -1
    }
    
    /// 二分法
    public class func search4(_ nums: [Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count - 1
        while left <= right {
            let middle = left + (right - left) / 2
            if nums[middle] > target {
                right = middle - 1
            } else if nums[left] < target {
                left = middle + 1
            } else {
                return middle
            }
        }
        return -1
    }
}
