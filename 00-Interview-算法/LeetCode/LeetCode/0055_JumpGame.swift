//
//  0055_JumpGame.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/31.
//

import Foundation

/*
 给定一个非负整数数组 nums ，你最初位于数组的 第一个下标 。
 数组中的每个元素代表你在该位置可以跳跃的最大长度。
 判断你是否能够到达最后一个下标。
 示例 1：
 输入：nums = [2,3,1,1,4]
 输出：true
 解释：可以先跳 1 步，从下标 0 到达下标 1, 然后再从下标 1 跳 3 步到达最后一个下标。
 示例 2：
 输入：nums = [3,2,1,0,4]
 输出：false
 解释：无论怎样，总会到达下标为 3 的位置。但该下标的最大跳跃长度是 0 ， 所以永远不可能到达最后一个下标。
 */

public class JumpGame {
    
    /// 迭代解法
    public class func canJump1(_ nums: [Int]) -> Bool {
        var currentIndex = 0
        for i in 0..<nums.count-1 {
            if nums[i] + i + 1 > nums.count {
                return true
            } else {
                currentIndex = max(currentIndex, i + nums[i])
                if currentIndex < i + 1 { // 没办法达到
                    return false
                }
            }
        }
        
        return currentIndex + 1 >= nums.count
    }
    
    public class func canJump(_ nums: [Int]) -> Bool {
        var coverIndex = 0
        for i in 0 ..< nums.count - 1 {
            if nums[i] + i + 1 >= nums.count {
                return true
            } else {
                
                let value = i + nums[i]
                coverIndex = value >= coverIndex ? value : coverIndex
                if coverIndex < i + 1 { return false }
            }
        }
        return coverIndex + 1 >= nums.count ? true : false
    }
}
