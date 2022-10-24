//
//  0046_Permutations.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/24.
//

import Foundation

/*
 给定一个不含重复数字的数组 nums ，返回其 所有可能的全排列 。你可以 按任意顺序 返回答案。
 示例 1：
 输入：nums = [1,2,3] 输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
 示例 2：
 输入：nums = [0,1] 输出：[[0,1],[1,0]]
 示例 3：
 输入：nums = [1] 输出：[[1]]
 */

public class Permutations {
    public class func permute(_ nums: [Int]) -> [[Int]] {
        var path = [Int]()
        var result = [[Int]]()
        var used = [Bool](repeating: false, count: nums.count)
        func backtracking() {
            
            if path.count == nums.count {
                result.append(path)
                return
            }
            
            for i in 0 ..< nums.count {
                
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
}
