//
//  0031_NextPermutation.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/16.
//

import Foundation

/*
 整数数组的一个 排列  就是将其所有成员以序列或线性顺序排列。
 例如，arr = [1,2,3] ，以下这些都可以视作 arr 的排列：
    [1,2,3]、[1,3,2]、[3,1,2]、[2,3,1] 。
 
 整数数组的下一个排列是指其整数的下一个字典序更大的排列。更正式地，如果数组的所有排列根据其字典顺序从小到大排列在一个容器中，那么数组的下一个排列.就是在这个有序容器中排在它后面的那个排列。如果不存在下一个更大的排列，那么这个数组必须重排为字典序最小的排列（即，其元素按升序排列）。

 例如，arr = [1,2,3] 的下一个排列是 [1,3,2] 。
 类似地，arr = [2,3,1] 的下一个排列是 [3,1,2] 。
 而 arr = [3,2,1] 的下一个排列是 [1,2,3] ，因为 [3,2,1] 不存在一个字典序更大的排列。
 给你一个整数数组 nums ，找出 nums 的下一个排列。

 必须 原地 修改，只允许使用额外常数空间。
 */
public class NextPermutation {
    
    /// 思路：从后往前遍历，遇到第一个变小的数字，则这个数字跟已经遍历过的比变小的数字第一个遇到比这个数字大的交换位置，然后将第一个变小之后的数字反转
    /// 如果遍历到数字的第一个还没遇到，则直接将原数组反转，
    ///
    /// 注意！！！！
    /// var nums = nums，会copy一个新的nums
    /// 这题要注意处理left == 0的情况
    public class func nextPermutation(_ nums: inout [Int]) {
        print(nums)
        guard nums.count > 1 else { return }
        var left:Int = nums.count - 2
        while left >= 0 && nums[left] >= nums[left + 1] {
            left -= 1
        }
        
        if left >= 0 {
            var right = nums.count - 1
            while right > 0 && nums[left] >= nums[right] {
                right -= 1
            }
            
            swap(&nums, left, right)
            print(nums)
        }
        
        reverseArray(&nums, left + 1, nums.count - 1)
        print(nums)
    }
    
    class func reverseArray(_ num: inout [Int], _ start: Int, _ end: Int) {
        var start = start, end = end
        while start < end {
            swap(&num, start, end)
            start += 1
            end -= 1
        }
    }
    
    class func swap(_ nums: inout [Int], _ left: Int, _ right: Int) {
        let temp = nums[left]
        nums[left] = nums[right]
        nums[right] = temp
    }
}
