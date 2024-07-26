//
//  0072_EditDistance.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/26.
//

import Foundation

/*
 给你两个单词word1和word2,请返回将word1转换成word2所使用的最少操作数。
 你可以对一个单词进行如下三种操作：
 插入一个字符 删除一个字符 替换一个字符
 */

public class EditDistance {
    public class func minDistance(_ word1: String, _ word2: String) -> Int {
        guard word1.count * word2.count > 0 else {return word1.count + word2.count}
        
        let wordArray1:[Character] = Array(word1)
        let wordArray2:[Character] = Array(word2)
        let n:Int = word1.count
        let m:Int = word2.count
        var dp:[[Int]] = [[Int]](repeating: [Int](repeating: 0, count: m + 1), count: n + 1)
        
        for i in 0..<n+1 { // 边界情况
            dp[i][0] = i
        }
        
        for j in 0..<m+1 { // 边界情况
            dp[0][j] = j
        }
        
        for i in 1..<n+1 { // 需要边界值，所以需要n+1，m+1
            for j in 1..<m+1 {
                if wordArray1[i - 1] == wordArray2[j - 1] { // 剪枝
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(dp[i - 1][j], dp[i - 1][j - 1], dp[i][j - 1]) + 1
                }
            }
        }
        
        return dp[n][m]
    }
}
