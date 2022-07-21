//
//  0202_HappyNum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/19.
//

import Foundation

public class HappyNum {
    public class func isHappy(_ n: Int) -> Bool {
        
        var set: Set<Int> = Set<Int>()
        
        var currentNum = self.isHa(n)
        while currentNum != 1 {
            if set.contains(currentNum) {
                return false
            } else {
                set.insert(currentNum)
                currentNum = self.isHa(currentNum)
            }
        }
        return true
    }
    
    public class func isHa(_ n: Int) -> Int {
        var num = n
        var sum = 0
        while num > 0 {
            let temp = num % 10
            sum += temp * temp
            num /= 10
        }
        return sum
    }
}
