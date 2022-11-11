//
//  0435_NonOverlappingIntervals.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/8.
//

import Foundation

/*
 给定一个区间的集合 intervals ，其中 intervals[i] = [starti, endi] 。返回 需要移除区间的最小数量，使剩余区间互不重叠 。
 示例 1:
 输入: intervals = [[1,2],[2,3],[3,4],[1,3]] 输出: 1
 解释: 移除 [1,3] 后，剩下的区间没有重叠。
 示例 2:
 输入: intervals = [ [1,2], [1,2], [1,2] ] 输出: 2
 解释: 你需要移除两个 [1,2] 来使剩下的区间没有重叠。
 示例 3:
 输入: intervals = [ [1,2], [2,3] ] 输出: 0
 解释: 你不需要移除任何区间，因为它们已经是无重叠的了。
 */

public class NonOverlappingIntervals {
    public class func eraseOverlapIntervals(_ intervals: [[Int]]) -> Int {
        let sortArray = intervals.sorted { n1, n2 in
            return n1[1] < n2[1]
        }
        
        var end = sortArray[0].last!
        var count = 1
        for i in 1 ..< sortArray.count {
            if sortArray[i].first! >= end {
                end = sortArray[i].last!
                count += 1
            }
        }
        return intervals.count - count
    }
}
