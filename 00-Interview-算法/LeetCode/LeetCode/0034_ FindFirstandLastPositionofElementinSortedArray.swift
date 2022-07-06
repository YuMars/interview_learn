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
        let leftBorder: Int = getLeftBorder(nums, target)
        let rightBorder: Int = getRightBorder(nums, target)
        
        if leftBorder == -2 , rightBorder == -2 { return [-1, -1]}
        if rightBorder - leftBorder > 1 { return [leftBorder + 1, rightBorder - 1]}
        return [-1, -1]
        
    }
    
    func getLeftBorder(_ nums:[Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count - 1
        var leftBorder: Int = -2
        while (left <= right) {
            let middle = left + (right - left) / 2
            if (nums[middle] >= target) {
                right = middle - 1
                leftBorder = right
            } else {
                left = middle + 1
            }
        }
        return leftBorder
    }
    
    func getRightBorder(_ nums:[Int], _ target: Int) -> Int {
        // target在数组左边，或右边
        // target在数组范围中，且不存在target
        // target在数组范围中，且存在target
        // [left,right]
        var left: Int = 0
        var right: Int = nums.count - 1
        var rightBorder: Int = -2
        while (left <= right) {
            let middle = left + (right - left) / 2
            if (nums[middle] > target) {
                right = middle - 1
            } else {
                left = middle + 1
                rightBorder = left
            }
        }
        return rightBorder
    }
}
