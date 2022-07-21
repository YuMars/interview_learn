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
    
    /// 哈希解法
    public class func twoSum2(_ nums:[Int], _ target:Int) -> [Int] {
        var map = [Int : Int]()
        for (index, value) in nums.enumerated() {
            if let v = map[target - value] {
                return [v, index]
            } else {
                map[value] = index
            }
        }
        return []
    }
}
