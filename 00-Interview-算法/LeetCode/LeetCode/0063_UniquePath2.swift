//
//  0063_UniquePath2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/18.
//

import Foundation

public class UniquePath2 {
    public class func uniquePathsWithObstacles(_ obstacleGrid: [[Int]]) -> Int {
        let n: Int = obstacleGrid.count
        let m: Int = obstacleGrid[0].count;
        var arr:[Int] = [Int](repeating: 0, count: m);
        
        arr[0] = obstacleGrid[0][0] == 0 ? 1 : 0;
        for i in 0 ..< n {
            for j in 0 ..< m {
                if (obstacleGrid[i][j] == 1) {
                    arr[j] = 0;
                    continue;
                }
                if (j - 1 >= 0 && obstacleGrid[i][j - 1] == 0) {
                    arr[j] += arr[j - 1];
                }
            }
        }
        
        return arr[m - 1];
    }
    
    public class func uniquePathsWithObstacles2(_ obstacleGrid: [[Int]]) -> Int {
        // 确定dp[x][y]的含义
        // 确定递推公司 dp[x][y] = dp[x-1][y] + dp[x][y-1]
        // 初始化dp
        // 遍历
        //
        guard obstacleGrid.count > 0 else { return 0}
        
        let n: Int = obstacleGrid.count
        let m: Int = obstacleGrid.first!.count
        
        var dp:[[Int]] = [[Int]](repeating: [Int](repeating: 0, count: m + 1), count: n + 1)
        
        for i in 0 ..< n {
            if obstacleGrid[i][0] == 0 {
                dp[i][0] = 1
            }
        }
        
        for i in 0 ..< m {
            if obstacleGrid[0][i] == 0 {
                dp[0][i] = 1
            }
        }
        
        for x in 1 ... n {
            for y in 1 ... m {
                dp[x][y] = obstacleGrid[x][y] == 0 ? dp[x-1][y] + dp[x][y-1] : 0
            }
        }
        
        return dp[n][m]
    }
}
