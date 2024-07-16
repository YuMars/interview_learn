//
//  0033_SearchInRotatedSortedArray.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/16.
//

import Foundation

var downC:Int = 0

public class SearchInRotatedSortedArray {
    public class func search(_ nums: [Int], _ target: Int) -> Int {
        let n = nums.count
        if n == 0 {
            return -1
        }
        
        if n == 1 {
            return nums[0] == target ? 0 : -1
        }
        
        var left: Int = 0
        var right: Int = n - 1
        while left <= right {
            let middle = (left + right) / 2
            if nums[middle] == target {
                return middle
            }
            
            if nums[0] <= nums[middle] {
                if nums[0] <= target && target < nums[middle] {
                    right -= 1
                } else {
                    left += 1
                }
            } else {
                if nums[middle] < target && target <= nums[n - 1] {
                    left = middle + 1;
                } else {
                    right = middle - 1;
                }
            }
        }
        return -1
    }
    
    
    /// 快速排序
    public class func quickSort<T: Comparable>(_ array: inout [T], low: Int, high: Int) {
        guard low < high else { return }
        var count = 0
        let pivotIndex = partition(&array, low: low, high: high, &count)
        quickSort(&array, low: low, high: pivotIndex - 1)
        quickSort(&array, low: pivotIndex + 1, high: high)
        
    }

    public class func partition<T: Comparable>(_ array: inout [T], low: Int, high: Int, _ count: inout Int) -> Int {
        let pivot = array[high]
        var i = low - 1
        
        for j in low..<high {
            if array[j] <= pivot {
                i += 1
                count += 1
                downC += 1
                print("count", count, "downc", downC)
                array.swapAt(i, j)
                print(array)
            }
        }
        array.swapAt(i + 1, high)
        print(array)
        return i + 1
    }
    
    public class func swap(_ nums: inout [Int], _ left: Int, _ right: Int) {
        let temp = nums[left]
        let left = left
        let right = right
        nums[left] = nums[right]
        nums[right] = temp
    }
}
