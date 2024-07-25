//
//  0056_MergeIntervals.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/9.
//

import Foundation

/*
 以数组 intervals 表示若干个区间的集合，其中单个区间为 intervals[i] = [starti, endi] 。请你合并所有重叠的区间，并返回 一个不重叠的区间数组，该数组需恰好覆盖输入中的所有区间 。
 */

public class MergeIntervals {
    
    public class func merge1(_ intervals: [[Int]]) -> [[Int]] {
        
    }
    
    public class func merge(_ intervals: [[Int]]) -> [[Int]] {
        let sortArray = intervals.sorted { p1, p2 in
            return p1.first! < p2.first!
        }
        
        var result = [[Int]]()
        result.append(sortArray[0])
        for i in 0 ..< sortArray.count {
            let minV:Int = sortArray[i][0]
            let maxV:Int = sortArray[i][1]
            
            var edit: Bool = false
            for j in 0 ..< result.count {
                let cMinV:Int = result[j][0]
                let cMaxV:Int = result[j][1]
                
                if (minV <= cMinV && cMinV <= maxV) || (cMinV <= minV && minV <= cMaxV) {
                    result[j][0] = min(minV, cMinV)
                    result[j][1] = max(maxV, cMaxV)
                    edit = true
                    break
                }
            }
            if !edit {
                result.append(sortArray[i])
            }
        }
        return result
    }
}
