//
//  0077_Combinations.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/11.
//

import Foundation

/*
 给定两个整数 n 和 k，返回范围 [1, n] 中所有可能的 k 个数的组合。
 你可以按 任何顺序 返回答案。
 */
public class Combinations {
    
    // 回溯+剪枝
    public class func combine(_ n: Int, _ k: Int) -> [[Int]] {
        var path = [Int]()
        var result = [[Int]]()
        
        func backtracking(start: Int) {
            if path.count == k {
                result.append(path)
                return
            }
            
            // 1.单层逻辑
            // let end = n
            
            // 2.剪枝优化
            let end = n - (k - path.count) + 1
            guard start <= end else { return }
            for i in start ... end {
                path.append(i)
                backtracking(start: i + 1)
                path.removeLast() // 回溯，撤销处理的结点
            }
        }
        
        backtracking(start: 1)
        return result
    }
}
