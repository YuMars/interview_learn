//
//  0090_Subsets2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/21.
//

import Foundation

/*
 给你一个整数数组 nums ，其中可能包含重复元素，请你返回该数组所有可能的子集（幂集）。
 解集不能包含重复的子集。返回的解集中，子集可以按任意顺序排列。
 示例 1：
 输入：nums = [1,2,2] --- 输出：[[],[1],[1,2],[1,2,2],[2],[2,2]]
 示例 2：
 输入：nums = [0] -- 输出：[[],[0]]
 */

public class Subsets2 {
    public class func subsetsWithDup(_ nums: [Int]) -> [[Int]] {
        var result = [[Int]]()
        var path = [Int]()
        
        let sortNum = nums.sorted()
        func backtracking(startIndex: Int) {
            // 第二种方法加入数据重复项判断
            
            //if !result.contains(path) { /
                result.append(path) // 所有子集
            //}
            
            for i in startIndex ..< sortNum.count {
                
                // 重复项去重
                if i > startIndex, sortNum[i] == sortNum[i - 1] { continue }
                
                path.append(sortNum[i])
                backtracking(startIndex: i + 1)
                path.removeLast()
            }
        }
        
        backtracking(startIndex: 0)
        return result
    }
}
