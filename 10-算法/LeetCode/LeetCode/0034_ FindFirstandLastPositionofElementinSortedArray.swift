//
//  0034_ FindFirstandLastPositionofElementinSortedArray.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/4/11.
//

import Foundation


/*
 给定一个按照升序排列的整数数组 nums，和一个目标值 target。找出给定目标值在数组中的开始位置和结束位置。
 如果数组中不存在目标值 target，返回 [-1, -1];
 进阶：你可以设计并实现时间复杂度为 $O(\log n)$ 的算法解决此问题吗？
 */

class FindFirstandLastPositionofElementinSortedArray {
    
    // 暴力查找(不符合O(log n))
    func searchRange(_ nums: [Int], _ target: Int) -> [Int] {
        var left: Int = -1
        var right: Int = -1
        for index in 0..<nums.count {
            if nums[index] == target {
                
                if left == -1, left < index {
                    left = index
                }
                right = index
            }
        }
        return [left, right]
    }
    
    func searchRange2(_ nums: [Int], _ target: Int) -> [Int] {
        var leftBorder: Int = getLeftBorder(nums, target)
        var rightBorder: Int = getRightBorder(nums, target)
        
        return [-1, -1]
        
    }
    
    func getLeftBorder(_ nums:[Int], _ target: Int) -> Int {
        return -1
    }
    
    func getRightBorder(_ nums:[Int], _ target: Int) -> Int {
        return -1
    }
}
