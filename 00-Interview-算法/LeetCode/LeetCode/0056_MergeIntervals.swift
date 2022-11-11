//
//  0056_MergeIntervals.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/9.
//

import Foundation

public class MergeIntervals {
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
