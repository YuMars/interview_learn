//
//  0977_SquaresOfASortArray.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/6/27.
//

import Foundation

//给你一个按 非递减顺序 排序的整数数组 nums，返回 每个数字的平方 组成的新数组，要求也按 非递减顺序 排序。
/* 输入：nums = [-4,-1,0,3,10]
输出：[0,1,9,16,100]
解释：平方后，数组变为 [16,1,0,9,100]
排序后，数组变为 [0,1,9,16,100]
*/

class SquareOfASortArray {
    
    /// 暴力解法
    public class func sortedSquares(_ nums: [Int]) -> [Int] {
        
        var unsortArray = Array<Int>()
        for num in nums {
            unsortArray.append(num * num);
        }
        return unsortArray.sorted { s1, s2 in
            return s1 < s2
        }
    }
    
    /// 双指针解法
    public class func sortedSquares1(_ nums: [Int]) -> [Int] {
        var result = nums
        var left = 0
        var right = result.count - 1
        var cur = right
        while left <= right {
            let leftSq = nums[left] *  nums[left]
            let rightSq = nums[right] *  nums[right]
            
            if leftSq < rightSq {
                result[cur] = rightSq
                right -= 1
            } else {
                result[cur] = leftSq
                left += 1
            }
            
            cur -= 1
        }
        
        return result
    }
}
