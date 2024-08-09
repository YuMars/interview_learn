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
    
    
//    // 递归解法
    public class func numTrees1(_ n: Int) -> Int {
        guard n >= 2 else { return 1 } // n= 2的时候，有 1=root 2=right   和 2=root 1=left
        var result: Int = 0
        result = recursiveTree(n)
        return result
    }
    
    public class func recursiveTree(_ n: Int) -> Int {
        if n == 0 || n == 1 {
            return 1
        }
        var result: Int = 0
        for i in 1...n {
            result = result + recursiveTree(i - 1) * recursiveTree(n - i)
        }
        
        return result
    }
    
    // 递归优化解法
    public class func numTrees2(_ n: Int) -> Int {
        guard n >= 2 else { return 1 } // n= 2的时候，有 1=root 2=right   和 2=root 1=left
        var result: Int = 0
        var map: [Int: Int] = [Int: Int]()
        result = recursiveTree2(n, &map)
        return result
    }
    
    public class func recursiveTree2(_ n: Int, _ map: inout [Int: Int]) -> Int {
        
        if let value = map[n] {
            return value
        }
        
        if n == 0 || n == 1 {
            return 1
        }
        
        var result: Int = 0
        
        for i in 1...n {
            result = result + recursiveTree2(i - 1, &map) * recursiveTree2(n - i, &map)
        }
        
        map[n] = result
        
        return result
    }
    
    // 动态规划解法
    public class func numTrees3(_ n: Int) -> Int {
        var dp: [Int] = [Int](repeating: 0, count: n + 1)
        dp[0] = 0
        for i in 1...n {
            for j in 1...n {
                dp[i] += dp[j - 1] * dp[n - j]
            }
        }
        return dp[n]
        
    }
}
