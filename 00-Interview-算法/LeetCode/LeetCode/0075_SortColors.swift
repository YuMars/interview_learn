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
        var left: Int = 0
        var right: Int = nums.count - 1
    }
}
