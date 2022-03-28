//
//  0001_TwoSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/27.
//

import Foundation


class TwoSum {
    public class func twoSum(_ nums:[Int], _ target:Int) -> [Int] { // 暴力解法
        for i in 0...nums.count - 1 {
            for j in i + 1..<nums.count {
                if nums[i] + nums[j] == target {
                    return [i, j]
                }
            }
        }
        return []
        
    }
}
