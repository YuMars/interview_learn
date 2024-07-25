//
//  0064_MinimumPathSum.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/25.
//

import Foundation

/*
 给定一个包含非负整数的 m x n 网格 grid ，请找出一条从左上角到右下角的路径，使得路径上的数字总和为最小。
 说明：每次只能向下或者向右移动一步。
 */

public class MinimumPathSum {
    public class func minPathSum(_ grid: [[Int]]) -> Int {
        guard grid.count > 0 else {return 0}
        let rowIndex:Int = grid.count
        let colIndex:Int = grid[0].count
        var dp: [[Int]] = Array(repeating: Array(repeating: 0, count: colIndex), count: rowIndex)
        dp[0][0] = grid[0][0]
        for i in 1..<colIndex {
            dp[0][i] = dp[0][i - 1] + grid[0][i]
        }
        
        for i in 1..<rowIndex {
            dp[i][0] = dp[i - 1][0] + grid[i][0]
        }
        
        for i in 1..<rowIndex {
            for j in 1..<colIndex {
                dp[i][j] = min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j]
            }
        }
        
        return dp[rowIndex - 1][colIndex - 1]
    }
}
