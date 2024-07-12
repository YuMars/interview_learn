//
//  0004_MedianOfTwoSortedArrays.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/11.
//

import Foundation

public class MedianOfTwoSortedArrays {
    public class func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        let lengthN = nums1.count
        let lengthM = nums2.count
        
        // 长度为偶数，n+m / 2
        // 长度为奇数，n+m / 2 - 1
        
        return 0.0
    }
    
    func mergeSortArray(_ nums: [Int]) -> [Int] {
        guard nums.count > 1 else { return nums}
        let middle:Int = nums.count / 2
        let leftArray = mergeSortArray(Array(nums[0..<middle]))
        let rightArray = mergeSortArray(Array(nums[middle...]))
        
        return merge(leftArray, rightArray)
    }
    
    func merge(_ leftArray:[Int], _ rightArray:[Int]) -> [Int] {
        var leftIndex:Int = 0
        var rightIndex:Int = 0
        
        var mergedArray:[Int] = [Int]()
        while leftIndex < leftArray.count && rightIndex < rightArray.count {
            
            let left = leftArray[leftIndex]
            let right = rightArray[rightIndex]
            
            if left < right {
                leftIndex += 1
                mergedArray.append(left)
            } else if left > right {
                rightIndex += 1
                mergedArray.append(right)
            } else {
                mergedArray.append(left)
                mergedArray.append(right)
                leftIndex += 1
                rightIndex += 1
            }
            
        }
        
        return mergedArray
    }
}
