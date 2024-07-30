//
//  0078_Subsets.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/20.
//

import Foundation

/*
 给你一个整数数组 nums ，数组中的元素 互不相同 。返回该数组所有可能的子集（幂集）。
 解集 不能 包含重复的子集。你可以按 任意顺序 返回解集。
 示例 1：
 输入：nums = [1,2,3] ----- 输出：[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]
 示例 2：
 输入：nums = [0] ----- 输出：[[],[0]]
 */

public class SubSets {
    
    public class func subsets1(_ nums: [Int]) -> [[Int]] {
        var result = [[Int]]()
        var path = [Int]()
        
        backtracking(nums, 0, &result, &path)
        return result
    }
    
    public class func backtracking(_ nums:[Int], _ index: Int, _ result: inout [[Int]], _ path:inout [Int]) {
        
        result.append(path)
        
        for i in index..<nums.count {
            path.append(nums[i])
            backtracking(nums, i + 1, &result, &path)
            path.removeLast()
        }
    }
    
    public class func subsets(_ nums: [Int]) -> [[Int]] {
        var result = [[Int]]()
        var path = [Int]()
        
        func backtracking(startIndex: Int){
            
            result.append(path) // 子集，不存在约束条件,收集所有数据
            
            for i in startIndex..<nums.count {
                path.append(nums[i])
                backtracking(startIndex: i + 1)
                path.removeLast()
            }
            
        }
        backtracking(startIndex: 0)
        return result
    }
}
