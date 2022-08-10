//
//  0239_SlidingWindowMaximum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/29.
//

import Foundation

public class SlidingWindowMaximum {
    
    // 队列取最大法
    public class func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
        var result = [Int]()
        var window = [Int]()
        var right = 0
        var left = right - k + 1
        
        while right < nums.count {
            let value = nums[right]
            
            // 窗口移动，丢弃左边数
            if left > 0, left - 1 == window.first {
                window.removeFirst()
            }
            
            // 保证末尾的是最大的
            while !window.isEmpty, value > nums[window.last!] {
                window.removeLast()
            }
            
            window.append(right) // 添加值对应的索引
            
            if left >= 0 { // 窗口形成
                result.append(nums[window.first!])
            }
            right += 1
            left += 1
        }
        return result
    }
}


