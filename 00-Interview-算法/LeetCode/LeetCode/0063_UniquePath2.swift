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
}
