//
//  main.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/3/27.
//

import Foundation

// 704
var nums = [-1,0,3,5,9,12] //[-1,0,3,5,9,12]
var target = 9
var index: Int = BinarySearch.search2(nums, target)
print("BinarySearch:" + "\(index)")

// 35
nums = [1,3,5,6]
target = 0
index = SearchInsertPosition.searchInsert(nums, target)
print("SearchInsertPosition:" + "\(index)")

nums = [3,2,2,3]
target = 3
index = RemoveElement.removeElement1(&nums, target)
print("RemoveElement" + "\(index)")
