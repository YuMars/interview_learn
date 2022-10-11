//
//  0216_CombinationSum3.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/11.
//

import Foundation

/*
 找出所有相加之和为 n 的 k 个数的组合，且满足下列条件：
 只使用数字1到9
 每个数字 最多使用一次
 */

public class CombinationSum3 {
    public class func combinationSum3(_ k: Int, _ n: Int) -> [[Int]] {
        var path = [Int]()
        var result = [[Int]]()
        func backtracking(sum: Int,startIndex: Int) {
            
            // 剪枝
            if sum > n { return }
            
            if path.count == k {
                if sum == n {
                    result.append(path)
                }
                return
            }
            
            let end = 9
            guard startIndex <= end else { return }
            for i in startIndex ... end {
                path.append(i)
                backtracking(sum: sum + i, startIndex: i + 1)
                path.removeLast()
            }
        }
        backtracking(sum: 0, startIndex: 1)
        return result
    }
}
