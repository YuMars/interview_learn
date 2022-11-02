//
//  0045_JumpGame2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/31.
//

import Foundation

public class JumpGame2 {
    public class func jump(_ nums: [Int]) -> Int {
        
        if nums.count < 1 { return 0 }
        
        var rightBoundary = 0 // 当前覆盖的最远距离下标
        var stepCount = 0 // 记录走的最大步数
        var currEnd = 0 // 下一步覆盖的最远距离下标
        for i in 0..<nums.count - 1 {
            
            // 更新下一步覆盖的最远距离下标
            rightBoundary = max(rightBoundary, nums[i] + i)

            if i == currEnd { // 遇到当前覆盖的最远距离下标
                currEnd = rightBoundary  // 更新当前覆盖的最远距离下标
                stepCount += 1
            }
        }

        return stepCount
    }
}
