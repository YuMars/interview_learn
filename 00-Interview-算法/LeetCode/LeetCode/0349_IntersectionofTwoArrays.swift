//
//  0349_IntersectionofTwoArrays.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/18.
//

import Foundation

public class IntersectionofTwoArrays {
    public class func intersection(_ nums1: [Int], _ nums2: [Int]) -> [Int] {
        var set1: Set<Int> = Set<Int>()
        var set2: Set<Int> = Set<Int>()
        for num in nums1 {
            set1.insert(num)
        }
        
        for num in nums2 {
            if set1.contains(num) {
                set2.insert(num)
            }
        }
        
        return Array(set2)
    }
}
