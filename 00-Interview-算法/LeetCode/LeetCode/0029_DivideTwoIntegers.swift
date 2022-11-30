//
//  0029_DivideTwoIntegers.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/29.
//

import Foundation

/*
 给定两个整数，被除数 dividend和除数divisor。将两数相除，要求不使用乘法、除法和 mod运算符。
 返回被除数 dividend 除以除数 divisor 得到的商。
 整数除法的结果应当截去（truncate）其小数部分，例如：truncate(8.345) = 8 以及 truncate(-2.7335) = -2
 示例 1:
 输入: dividend = 10, divisor = 3 输出: 3
 解释: 10/3 = truncate(3.33333..) = truncate(3) = 3
 示例 2:
 输入: dividend = 7, divisor = -3 输出: -2
 解释: 7/-3 = truncate(-2.33333..) = -2
 */

public class DivideTwoIntegers {
    
    public class func divide(_ dividend: Int, _ divisor: Int) -> Int {
        if divisor == 0 {return 0}
        if divisor == 1 {return dividend}
        
        if divisor == -1 {
            return dividend > Int(Int32.min) ? -dividend : Int(Int32.max)
        }
        
        let sign: Bool = (divisor > 0 && dividend > 0) || (dividend < 0 && divisor < 0)
        let dividend: Int = dividend > 0 ? dividend : -dividend
        let divisor: Int = divisor > 0 ? divisor : -divisor
        
        let result: Int = divide2(dividend, divisor)
        
        func divide2(_ a:Int, _ b: Int) -> Int {
            if a < b { return 0}
            var count: Int = 1
            var result: Int = b
            while result + result < a {
                count += count
                result += result
            }
            return count + divide2(a - result, b)
        }
        return sign ? result : -result
    }
    
    public class func divide2(_ dividend: Int, _ divisor: Int) -> Int {
        
        func divide(_ a: Int, _ b: Int) -> Int {
            if a < b { return 0 }
            var count = 1
            var result = b
            while result + result < a {
                count += count
                result += result
            }
            return count + divide(a - result, b)
        }
        
        // 1.处理被除数边界值： Int.max Int.min
        // 2.处理除数边界值：-1，1
        // 3.判断结果的正负号
        // 3.用除数加倍的方式，不断累加计算商
        if dividend == 0 { return 0 }
        if divisor == 1 { return dividend }
        //如果被除数比最小值还小，除以-1之后，就会比边界值还打，所以此时返回最大边界值，其他情况，返回相反数
        if divisor == -1 {
            return dividend > Int(Int32.min) ? -dividend : Int(Int32.max)
        }
        
        // 正负号
        let sign = (dividend > 0 && divisor > 0) || (dividend < 0 && divisor < 0)
        let dividend = dividend > 0 ? dividend : -dividend
        let divisor = divisor > 0 ? divisor : -divisor
        let result = divide(dividend, divisor)
        return sign ? result : -result
    }
}
