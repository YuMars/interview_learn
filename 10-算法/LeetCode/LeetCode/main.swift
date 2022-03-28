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
let index: Int = BinarySearch.search2(nums, target)
print("BinarySearch:" + "\(index)")
