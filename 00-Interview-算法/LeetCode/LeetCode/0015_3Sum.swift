//
//  0015_3Sum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/20.
//

import Foundation

public class ThreeSum {
    
    /// 双指针
    /// 三个指针，第一个指针从头开始遍历，另外两个左右指针则从两边收缩
    public class func threeSum1(_ nums: [Int]) -> [[Int]] {
        guard nums.count >= 3 else { return []}
        let sortedArray: [Int] = nums.sorted(by:{ $0<$1})
        var resultArray: [[Int]] = [[Int]]()
        for i in 0..<sortedArray.count {
            
            if sortedArray[i] > 0 { return resultArray } // 剪枝
            
            if i > 0 && sortedArray[i] == sortedArray[i - 1] { continue } // 重复操作，剪枝
            
            var left: Int = i + 1
            var right: Int = sortedArray.count - 1
            
            while left < right {
                
                if sortedArray[left] + sortedArray[right] + sortedArray[i] > 0 {
                    right -= 1
                } else if sortedArray[left] + sortedArray[right] + sortedArray[i] < 0 {
                    left += 1
                } else {
                    resultArray.append([sortedArray[i], sortedArray[left], sortedArray[right]])
                    
                    while left < right && sortedArray[left] == sortedArray[left + 1] { // 剪枝去重复
                        left += 1
                    }
                    
                    while left < right && sortedArray[right] == sortedArray[right - 1] { // 剪枝去重复
                        right -= 1
                    }
                    
                    
                    left += 1
                    right -= 1
                }
            }
        }
        return resultArray
    }
    
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
