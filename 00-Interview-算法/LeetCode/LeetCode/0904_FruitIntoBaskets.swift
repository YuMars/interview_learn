//
//  0904_FruitIntoBaskets.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/6/30.
//

import Foundation

class FruitIntoBaskets {
    
    /// 暴力解法
    public class func totalFruit(_ fruits: [Int]) -> Int {
        var maxCount = 0
        
        for start in 0..<fruits.count {
            
            var startTotal = 1
            var notSameCount = 0
            var another = fruits[start]
            for next in (start + 1) ..< fruits.count {
                if fruits[next] != fruits[start] && fruits[next] != another {
                    another = fruits[next]
                    notSameCount += 1
                    
                    if notSameCount > 1 {
                        if startTotal > maxCount {
                            maxCount = startTotal
                        }
                        break
                    }
                }
                
                startTotal += 1
            }
            
            if startTotal > maxCount {
                maxCount = startTotal
            }
        } 
        
        return maxCount
    }
    
    /// 滑动窗口
//    public class func totalFruit1(_ fruits: [Int]) -> Int {
//        var maxCount = 0
//
//        for start in 0..<fruits.count {
//
//        }
//    }
}
