//
//  0001_TwoSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/27.
//

import Foundation


class TwoSum {
    
    
    /// 暴力解法
    /// 时间复杂付O(n²)，空间复杂度O(1)
    public class func twoSum(_ nums:[Int], _ target:Int) -> [Int] {
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
    /// 时间复杂度O(n),空间复杂度O(n)
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
    
    /*   practice  */
    public class func twoSum3(_ nums: [Int], _ target: Int) -> [Int] {
        //
        for i in 0..<nums.count {
            for j in i+1..<nums.count {
                if nums[i] + nums[j] == target {
                    return [i,j]
                }
            }
        }
        return []
    }
    
    public class func twoSum4(_ nums: [Int], _ target: Int) -> [Int] {
        var map:[Int : Int] = [Int : Int]()
        for (index, value) in nums.enumerated() {
            if let res = map[target - value] {
                return [res, index]
            } else {
                map[value] = index
            }
        }
        return []
    }
    
}
