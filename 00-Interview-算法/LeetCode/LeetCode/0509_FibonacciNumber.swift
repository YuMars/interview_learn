//
//  0509_FibonacciNumber.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/15.
//

import Foundation

/*
 斐波那契数 （通常用 F(n) 表示）形成的序列称为 斐波那契数列 。该数列由0和1开始，后面的每一项数字都是前面两项数字的和。也就是：
 F(0) = 0，F(1) = 1
 F(n) = F(n - 1) + F(n - 2)，其中 n > 1
 给定 n ，请计算 F(n) 。
 示例 1：
 输入：n = 2 输出：1
 解释：F(2) = F(1) + F(0) = 1 + 0 = 1
 示例 2：
 输入：n = 3 输出：2
 解释：F(3) = F(2) + F(1) = 1 + 1 = 2
 */

public class FibonacciNumber {
    // 动态规划
    public class func fib(_ n: Int) -> Int {
        // 1.确定dp[i]的含义     dp[i] = 第i个斐波那契数
        // 2.确定递推公式         dp[i] = dp[i - 1] + dp[i - 2]
        // 3.数组如何初始化       dp[0] = 0 dp[1] = 1
        // 4.遍历循序
        // 5.打印数组
        if n <= 1 { return n}
        
        var dp:[Int] = [Int]()
        dp.append(0)
        dp.append(1)
        for _ in 2 ... n {
            let sum:Int = dp[0] + dp[1]
            dp[0] = dp[1]
            dp[1] = sum
            
        }
        return dp[1]
    }
    
    // 递归
    public class func fib2(_ n: Int) -> Int {
        func subFib(_ n: Int) -> Int {
            if n == 0 { return 0 }
            if n == 1 { return 1 }
            return subFib(n - 1) + subFib(n - 2)
        }
        return subFib(n)
    }
}
