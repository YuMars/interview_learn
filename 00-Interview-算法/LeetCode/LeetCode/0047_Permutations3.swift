//
//  0047_Permutations3.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/24.
//

import Foundation

public class Permutations3 {
    public class func permuteUnique(_ nums: [Int]) -> [[Int]] {
        let nums = nums.sorted()
        var path = [Int]()
        var result = [[Int]]()
        var used = [Bool](repeating: false, count: nums.count)
        func backtracking() {
            if path.count == nums.count {
                result.append(path)
                return
            }
            
            
            for i in 0 ..< nums.count {
                
                if i > 0, nums[i] == nums[i - 1], !used[i - 1]{ continue }
                
                if used[i] { continue }
                used[i] = true
                path.append(nums[i])
                backtracking()
                path.removeLast()
                used[i] = false
            }
        }
        
        backtracking()
        return result
    }
    
    public class func permuteUnique2(_ nums: [Int]) -> [[Int]] {
        let nums = nums.sorted()
        var path = [Int]()
        var result = [[Int]]()
        var used = [Bool](repeating: false, count: nums.count)
        func backtracking() {
            
            if path.count == nums.count {
                result.append(path)
                return
            }
            
            var set = Set<Int>()
            for i in 0 ..< nums.count {
                
                if set.contains(nums[i]) { continue }
                
                if used[i] { continue }
                used[i] = true
                set.insert(nums[i])
                path.append(nums[i])
                backtracking()
                path.removeLast()
                used[i] = false
            }
        }
        
        backtracking()
        return result
    }
}
