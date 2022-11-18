//
//  0062_UniquePath.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/17.
//

import Foundation

/*
 一个机器人位于一个 m x n 网格的左上角 （起始点在下图中标记为 “Start” ）。
 机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为 “Finish” ）。
 问总共有多少条不同的路径
 示例 1:
 输入：m = 3, n = 7 输出：28
 示例 2：
 输入：m = 3, n = 2 输出：3
 解释：
 从左上角开始，总共有 3 条路径可以到达右下角。
 1. 向右 -> 向下 -> 向下
 2. 向下 -> 向下 -> 向右
 3. 向下 -> 向右 -> 向下
 示例 3：
 输入：m = 7, n = 3 输出：28
 示例 4：
 输入：m = 3, n = 3 输出：6
 */

public class UniquePath {
    public class func uniquePaths(_ m: Int, _ n: Int) -> Int {
        // 1.确定dp[x][y]的含义     dp[x][y] = 到达x,y这个位置的可能路劲
        // 2.确定递推公式           dp[x][y] = dp[x-1][y] + dp[x][y-1]
        // 3.数组如何初始化          dp[0][0] = 1
        // 4.遍历循序
        // 5.打印数组
        
        // 1x2
        var dp:[[Int]] = [[Int]](repeating: [Int](repeating: 1, count: n), count: m)
        
        for x in 1 ..< m {
            for y in 1 ..< n {
                dp[x][y] = dp[x-1][y] + dp[x][y-1]
                print("dp", x , y , dp[x][y])
            }
        }
        
        return dp[m - 1][n - 1]
    }
}
