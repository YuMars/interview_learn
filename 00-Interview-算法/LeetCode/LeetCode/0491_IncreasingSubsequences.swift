//
//  0491_IncreasingSubsequences.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/21.
//

import Foundation

/*
 给你一个整数数组 nums ，找出并返回所有该数组中不同的递增子序列，递增子序列中 至少有两个元素 。你可以按 任意顺序 返回答案。
 数组中可能含有重复元素，如出现两个整数相等，也可以视作递增序列的一种特殊情况。
 示例 1：
 输入：nums = [4,6,7,7] --- 输出：[[4,6],[4,6,7],[4,6,7,7],[4,7],[4,7,7],[6,7],[6,7,7],[7,7]]
 示例 2：
 输入：nums = [4,4,3,2,1] --- 输出：[[4,4]]
 */

public class IncreasingSubsequences {
    public class func findSubsequences(_ nums: [Int]) -> [[Int]] {
        var result = [[Int]]()
        var path = [Int]()
        func backtracking(startIndex: Int) {
            
            if path.count >= 2 {
                if !result.contains(path) {
                    result.append(path)
                }
            }
            
            for i in startIndex ..< nums.count {
                
                // 1.nums[i] == nums[i - 1],continue用于去除重复项
                // 2.nums[i] > nums[i - 1],continue去掉非递增的元素
                // 3.i > 0,continue防止i<0，数组越界
                print("before-----" , "startIndex---", startIndex, "i---", i, path)
                if i > startIndex, nums[i] == nums[i - 1] { continue }
                
                //if !path.isEmpty, nums[i] < path.last! {continue}
                
                path.append(nums[i])
                print("append-----" , "startIndex---", startIndex, "i---", i, path)
                backtracking(startIndex: i + 1)
                path.removeLast()
                print("after-----" , "startIndex---", startIndex, "i---", i, path)
            }
            
        }
        backtracking(startIndex: 0)
        
        return result
    }
    
    public class func findSubsequences2(_ nums: [Int]) -> [[Int]] {
        var result = [[Int]]()
        var path = [Int]()
        func backtracking(startIndex: Int) {
            // 收集结果，但不返回，因为后续还要以此基础拼接
            if path.count > 1 {
                result.append(path)
            }

            var set = Set<Int>()
            let end = nums.count // 每层循环收集
            guard startIndex < end else {return} // 终止回溯
            for i in startIndex ..< end {
                let num = nums[i]
                print("取第", startIndex,"层","第",i,"个数",num, "path", path,"set有", set)
                if set.contains(num) {continue} // 跳过重复元素
                if !path.isEmpty, num < path.last! {continue}// 确保递增
                set.insert(num)
                path.append(num)
                backtracking(startIndex: i + 1)
                path.removeLast()
            }
        }
        backtracking(startIndex: 0)
        return result
    }
}
