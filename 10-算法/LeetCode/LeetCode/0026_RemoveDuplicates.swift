//
//  0026_RemoveDuplicates.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/5/27.
//

import Foundation

class RemoveDuplicates {
    
    // 自己写的(暴力解法)
    public class func removeDuplicates(_ nums: inout [Int]) -> Int {
        var totalRemove: Int = 0
        for fastIndex in 0 ..< nums.count {
            var slowIndex: Int = (fastIndex + 1)
            var removeCount: Int = 0
            let target = nums[fastIndex]
            
            if (fastIndex + 1) < (nums.count - totalRemove) {
                for i in (fastIndex + 1) ..< (nums.count - totalRemove) {
                    let value = nums[i]
                    //print("target = " + "\(target)" + " value = " + "\(value)" )
                    if value != target {
                        nums[slowIndex] = nums[i]
                        slowIndex += 1
                    } else {
                        removeCount += 1
                        //print("removeCount = " + "\(removeCount)")
                    }
                }
            }
            
            totalRemove += removeCount
            //print("nums = " + "\(nums)")
        }
        return nums.count - totalRemove
    }
    
    public class func removeDuplicates2(_ nums: inout [Int]) -> Int {
        let size = nums.count
        var slowIndex = 0
        for fastIndex in 0 ..< size {
            if nums[slowIndex] != nums[fastIndex] {
                slowIndex += 1 // slowIndex = 0的数据一定不是重复的，所以起码从1开始计算
                nums[slowIndex] = nums[fastIndex]
            }
        }
        return slowIndex + 1 // 从0开始，所以返回slowIndex+1
    }
}
