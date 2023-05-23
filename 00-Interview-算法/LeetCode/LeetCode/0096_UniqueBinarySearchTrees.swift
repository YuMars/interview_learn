//
//  0096_UniqueBinarySearchTrees.swift
//  LeetCode
//
//  Created by Red-Fish on 2023/5/23.
//

import Foundation

public class UniqueBinarySearchTrees {
    public class func numTrees(_ n: Int) -> Int {
        // 确定dp[i]的含义 dp[i] 数字i有多少种二叉搜索树
        /*
         二叉搜索树
         dp[1] = 1
         
         1为结点 + 2为结点
         dp[2] =   1                       2
                    2                        1
         1为结点(左子树有0个结点 * 右子树有2个结点) + 2为结点(左子树有1个结点 * 右子树有1个结点) + 3为结点(左子树有2个结点 * 右子树有0个结点)
         dp[3] = dp[0] * dp[2] + dp[1] * dp[1] + dp[2] * dp[0]
         
         
         j = 头结点总数
         dp[i] += dp[j - 1] * dp[i - j]
         
         */
        // 递推公式 dp[i] = dp[i - 1] +
        // 初始化dp数组
        // 遍历dp
        // 打印
        
        var dp: [Int] = [Int](repeating: 0, count: n + 1)
        for i in 1 ... n {
            for j in 1 ... i {
                dp[i] += dp[j - 1] * dp[i - j]
            }
        }
        return dp[n]
    }
}
