//
//  027_RemoveElement.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/5/26.
//

import Foundation

class RemoveElement {
    
    // 暴力解法(有问题)
    public class func removeElement1(_ nums: inout [Int], _ val: Int) -> Int {
        let size:Int = nums.count
        var resetSzie = size
    
        for var i in 0..<size {
            if nums[i] == val {
                for j in (i + 1)..<size {
                    nums[j - 1] = nums[j];
                }
                i -= 1 // 此处i没办法改变
                resetSzie -= 1
            }
        }
        return resetSzie
    }
    
    // 单向双指针解法
    public class func removeElement2(_ nums: inout [Int], _ val: Int) -> Int {
        var slowIndex: Int = 0
        
        for fastIndex in 0 ..< nums.count {
            if nums[fastIndex] != val {
                nums[slowIndex] = nums[fastIndex]
                slowIndex += 1
            }
        }
        
        return slowIndex
    }
}
