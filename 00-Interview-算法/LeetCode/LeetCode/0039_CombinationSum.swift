//
//  0039_CombinationSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/13.
//

import Foundation

/*
 给你一个 无重复元素 的整数数组 candidates 和一个目标整数 target ，找出 candidates 中可以使数字和为目标数 target 的 所有 不同组合 ，并以列表形式返回。你可以按 任意顺序 返回这些组合。

 candidates 中的 同一个 数字可以 无限制重复被选取 。如果至少一个数字的被选数量不同，则两种组合是不同的。

 对于给定的输入，保证和为 target 的不同组合数少于 150 个。
 */

public class CombinationSum {
    
    
    /// 回溯法
    public class func combinationSum1(_ candidates: [Int], _ target: Int) -> [[Int]] {
        var resultArray: [[Int]] = [[Int]]()
        let sum: Int = 0
        var path: [Int] = [Int]()
        backtrack(candidates, 0, &resultArray, &path, sum, target)
        return resultArray
    }
    
    public class func backtrack(_ candidates:[Int], _ index: Int, _ resultArray: inout [[Int]], _ path: inout [Int],_ sum: Int, _ target: Int) {
        if sum == target {
            resultArray.append(path)
            return
        }
        
        for i in index..<candidates.count {
            if candidates[i] + sum <= target {
                path.append(candidates[i])
                backtrack(candidates, i, &resultArray, &path, sum + candidates[i], target)
                path.removeLast()
            }
        }
    }
    
    public class func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
        
        var result = [[Int]]()
        var path = [Int]()
        func backtracking(index: Int, sum: Int) {
            
            if sum == target { // 终止条件
                result.append(path)
                return
            }
            
            let end = candidates.count
            guard index < end else { return }
            for i in index..<end {
                let value = candidates[i]
                
                if sum > target {continue} //   剪枝(重要)
                
                path.append(value)
                print("path append---" + "i:\(i)---" + "index:\(index)" + "---\(path)")
                backtracking(index: i, sum: sum + value)
                path.removeLast() // 回溯
                print("path remove---" + "i:\(i)---" + "index:\(index)" + "---\(path)")
            }
        }
        backtracking(index: 0, sum: 0)
        
        return result
    }
}
