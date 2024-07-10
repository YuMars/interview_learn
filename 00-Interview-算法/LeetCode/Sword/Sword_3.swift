//
//  Sword_3.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/4/25.
//

import Foundation

// 前n个数字二进制形式中1的个数

public class Sword_3 {
    
    // 1.遍历所有数字
    // 2.计算每个数字二进制形式1的个数
    // 3.计算数字n二进制中1的个数
    /*
     计算数字i二进制中1的个数
     i & (i - 1) 将二进制后i的最右边一位1转换成0,能执行一次说明二进制位还有1
     上述步骤一直执行下去直到 i & (i - 1) = 0
     */
    
    public class func theNumberOfNForBinaryOne1(_ n: Int) -> [Int] {
        
        var resultArray = Array(repeating: 0, count: n + 1)
        for i in 0...n {
            var j = i
            while j != 0 {
                resultArray[i] += 1
                j = j & (j - 1)
            }
        }
        return resultArray
    }
    
    
    // 根据i & (i - 1)是将数字i的最右边变成0，
    // 等于 i的二进制格式 比 i & (i - 1)的 二进制中1的个数多1个
    // 动态规划的方式 dp[i] = dp[i & (i - 1)] + 1
    public class func theNumberOfNForBinaryOne2(_ n: Int) -> [Int] {
        
         var resultArray = Array(repeating: 0, count: n
         + 1)
        resultArray[0] = 0
        for i in 1...n {
            resultArray[i] = resultArray[i & (i - 1)] + 1
        }
        return resultArray
    }
    
    // 根据 i/2 相当于将i右移一位
    // 如果i是偶数，i和i/2的二进制形式中1的个数相同
    // 如果i是奇数，i相当于i/2左移一位之后将最右边的0变成1，所以i是奇数，二进制形式中1个个数比i/2多一个
    // 3的二进制：11 ，6的二进制：110，7的二进制：111，所以可以根据3的二进制形式1的个数计算出6和7的二进制形式1的个数
    public class func theNumberOfNForBinaryOne3(_ n: Int) -> [Int] {
        
     var resultArray = Array(repeating: 0, count: n
     + 1)
        resultArray[0] = 0
        for i in 1...n {
            resultArray[i] = resultArray[i >> 1] + (i & 1) //<< 奇数+1，偶数+0
        }
        return resultArray
    }
}
