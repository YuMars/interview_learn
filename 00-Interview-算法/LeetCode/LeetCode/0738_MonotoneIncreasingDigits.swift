//
//  0738_MonotoneIncreasingDigits.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/10.
//

import Foundation

/*
 当且仅当每个相邻位数上的数字 x 和 y 满足 x <= y 时，我们称这个整数是单调递增的。
 给定一个整数 n ，返回 小于或等于 n 的最大数字，且数字呈 单调递增 。
 示例 1: 输入: n = 10 输出: 9
 示例 2: 输入: n = 1234 输出: 1234
 示例 3: 输入: n = 332 输出: 299  17743 0 0 0 0 0
 */

public class MonotoneIncreasingDigits {
    public class func monotoneIncreasingDigits(_ n: Int) -> Int {
        var pos = 1
        var result = n
        while (pos <= result / 10) {
            let n = result / pos % 100//从右开始每次取两位
            pos *= 10 //向左前进一位
            if (n / 10 > n % 10) {//判断十位数是否大于个位数
                //(result / pos) * pos)逐步将右边的尾数变成0的整数
                result = (result / pos) * pos - 1
            }
        }
        return result
    }
}
