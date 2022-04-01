//
//  0035_SearchInsertPosition.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/29.
//

import Foundation
// target = 5
// 1, 2, 3, 4, 6, 7, 8
// 0  1  2  3  4  5  6
class SearchInsertPosition {
    
    public class func searchInsert(_ nums: [Int], _ target: Int) -> Int {
        var left: Int = 0
        var right: Int = nums.count
        
        while left <= right {
            let middle = left + (right - left) / 2
            if nums[middle] < target {
                left = middle + 1
            } else if nums[middle] > target {
                right = middle - 1
            } else {
                return middle
            }
        }
        return right + 1
    }
    
}
