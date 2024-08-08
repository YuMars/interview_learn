//
//  0084_LargestRectangleInHistogram.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/8/2.
//

import Foundation

public class LargestRectangleInHistogram {
    /// 暴力解法一
    /// 遍历宽度W，在宽度W内对应最小高度H，面积=WxH   (minHeight x (right - left + 1))
    public class func argestRectangleArea(_ heights: [Int]) -> Int {
        let length: Int = heights.count
        var result: Int = 0
        for left in 0..<length {
            var minHeight = Int.max
            for right in 0..<length {
                minHeight = min(minHeight, heights[right])
                result = (right - left + 1) * minHeight
            }
        }
        
        return result
    }
    
    /// 暴力解法二
    /// 已当前高度H往两边延伸,直到高度小于当前高度H来确定其宽度W
    public class func argestRectangleArea1(_ heights: [Int]) -> Int {
        var result: Int = 0
        
        for mid in 0..<heights.count {
            var height = heights[mid]
            var left: Int = 0
            var right: Int = 0
            
            while left - 1 >= 0 && heights[left - 1] >= height {
                left -= 1
            }
            
            while right + 1 < heights.count && heights[right + 1] >= height {
                right += 1
            }
            
            result = max(result, (right - left + 1) * height)
        }
        
        return result
    }
    
    /// 单调栈
    public class func argestRectangleArea2(_ heights: [Int]) -> Int {
        let n: Int = heights.count
        var left: [Int] = [Int](repeating: -1, count: n)
        var right: [Int] = [Int](repeating: n, count: n)
        
        var stack: [Int] = [Int]()
        
        var result : Int = 0
        
        for i in 0..<n {
            while !stack.isEmpty && heights[stack.last!] >= heights[i] {
                stack.removeLast()
            }
            
            left[i] = (stack.isEmpty == true ? -1 : stack.last!)
            stack.append(i)
        }
        
        stack.removeAll()
        
        for i in (0..<n).reversed() {
            while !stack.isEmpty && heights[stack.last!] > heights[i] {
                stack.removeLast()
            }
            
            right[i] = stack.isEmpty == true ? n : stack.last!
            stack.append(i)
        }
        
        for i in 0..<n {
            result = max(result, (right[i] - left[i] - 1) * heights[i])
        }
        
        return result
    }
}
