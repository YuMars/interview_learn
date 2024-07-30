//
//  0075_SortColors.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/26.
//

import Foundation

public class SortColors {
    
    /// 计数排序
    public class func sortColors(_ nums: inout [Int]) {
        var minV: Int = Int.max
        var maxV: Int = Int.min
        for i in 0..<nums.count {
            minV = min(minV, nums[i])
            maxV = max(maxV, nums[i])
        }
        
        var arr:[Int] = Array(repeating: 0, count: maxV - minV + 1)
        for i in 0..<nums.count {
            arr[nums[i] - minV] += 1
        }
        
        var resultArray: [Int] = [Int]()
        for i in minV...maxV {
            while arr[i - minV] > 0 {
                arr[i - minV] -= 1
                resultArray.append(i + minV)
            }
        }
        
        nums = resultArray
        print(resultArray)
    }
    
    /// 快速排序
    public class func sortColors1(_ nums: inout [Int]) {
        var i: Int = 0
        var left: Int = 0
        var right: Int = nums.count - 1
        
        // 区间 i是循环变量，所以在当i <= right的时候循环结束,[left, i)是右开区间，是因为如果i是右闭区间，那么循环开始的时候在[left, i)中就会存在一个元素
        // [0, left) == 0
        // [left, i) == 1
        // (right, len - 1) == 2
        while i <= right {
            if nums[i] == 0 {
                swap(&nums, i, left)
                i += 1
            } else if nums[i] == 1 {
                i += 1
            } else { // num[i] == 2
                swap(&nums, i, right)
                right -= 1
            }
        }
    }
    
    public class func swap(_ nums: inout  [Int], _ left: Int, _ right: Int) {
        let temp: Int = nums[left]
        nums[left] = nums[right]
        nums[right] = temp
    }
}
