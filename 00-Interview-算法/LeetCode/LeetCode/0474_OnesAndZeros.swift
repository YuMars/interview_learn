//
//  0474_OnesAndZeros.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/25.
//

import Foundation

/*
 给你一个二进制字符串数组 strs 和两个整数 m 和 n 。
 请你找出并返回 strs 的最大子集的长度，该子集中 最多 有 m 个 0 和 n 个 1 。
 如果 x 的所有元素也是 y 的元素，集合 x 是集合 y 的 子集 。
 
 示例 1：
 输入：strs = ["10", "0001", "111001", "1", "0"], m = 5, n = 3 输出：4
 解释：最多有 5 个 0 和 3 个 1 的最大子集是 {"10","0001","1","0"} ，因此答案是 4 。
 其他满足题意但较小的子集包括 {"0001","1"} 和 {"10","1","0"} 。{"111001"} 不满足题意，因为它含 4 个 1 ，大于 n 的值 3 。
 
 示例 2：
 输入：strs = ["10", "0", "1"], m = 1, n = 1 输出：2
 解释：最大的子集是 {"0", "1"} ，所以答案是 2 。
 
 */

public class OnesAndZeros {
    public class func findMaxForm(_ strs: [String], _ m: Int, _ n: Int) -> Int {
        // 确定dp[i][j]的含义 背包容量为i和j的背包最大可以装dp[i][j]种组合
        // 递推公式 dp[i][j] = dp[i - x][j - y] + 1 x:strs[k]下0的个数 y:strs[k]下1的个数
        // 初始化dp dp[0][0] = 0
        // 遍历
        var dp: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for str in strs {
            var zero: Int = 0
            var one: Int = 0
            for char in str {
                if char == "0" {
                    zero += 1
                } else {
                    one += 1
                }
            }
            
            if zero <= m {
                for i in (zero ... m).reversed() {
                    if one <= n {
                        for j in (one ... n).reversed() {
                            dp[i][j] = max(dp[i][j], dp[i - zero][j - one] + 1)
                        }
                    }
                }
            }
        }
        return dp[m][n]
    }
}
