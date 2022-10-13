//
//  0040_CombinationSum2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/13.
//

import Foundation

/*
 给定一个候选人编号的集合 candidates 和一个目标数 target ，找出 candidates 中所有可以使数字和为 target 的组合。
 
 candidates 中的每个数字在每个组合中只能使用 一次 。
 
 注意：解集不能包含重复的组合。
 */

public class CombinationSum2 {
    public class func combinationSum2(_ candidates: [Int], _ target: Int) -> [[Int]] {
        
        let candidates = candidates.sorted()// 方便去重，排序
        var result = [[Int]]()
        var path = [Int]()
        
        func backtracking(sum: Int, index: Int) {
            if sum == target {
                result.append(path)
                return
            }
            
            let end = candidates.count
            guard index < end else { return }
            for i in index..<end {
                
                // candidates[i] == candidates[i - 1] 重复出现的数字去重
                if i > index, candidates[i] == candidates[i - 1] { continue }
                
                let value = candidates[i]
                
                if sum > target { continue }
                
                path.append(value)
                backtracking(sum: sum + value, index: i + 1)
                path.removeLast()
            }
        }
        backtracking(sum: 0, index: 0)
        return result
    }
}
