//
//  0015_3Sum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/20.
//

import Foundation

public class ThreeSum {
    // 哈希解法
    public class func threeSum(_ nums: [Int]) -> [[Int]] {
        if nums.count < 3 { return [] }
        
        var resultArray = [[Int]]()
        var totalSet: Set<Set<Int>> = Set<Set<Int>>()
        var dict = [Int : Int]()
        for index in 0 ..< nums.count {
            dict[nums[index]] = index
        }
        
        for indexI in 0 ..< nums.count {
            for indexJ in (indexI + 1) ..< nums.count {
                let target =  0 - (nums[indexI] + nums[indexJ])
                if let index = dict[target] { // 是否存在目标值
                    if index > indexJ { // 结果不在已选中的两个数字内
                        let subSet: Set = [nums[indexI], nums[indexJ], target] // 三个数字去重
                        if totalSet.contains(subSet) { // 用totalSet来去重三个数的值
                            continue
                        }
                        totalSet.insert(subSet)
                        resultArray.append([nums[indexI], nums[indexJ], target])
                    }
                }
            }
        }
        return resultArray
    }
}
