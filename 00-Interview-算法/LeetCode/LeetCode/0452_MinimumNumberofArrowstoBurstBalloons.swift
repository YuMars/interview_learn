//
//  0452_MinimumNumberofArrowstoBurstBalloons.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/7.
//

import Foundation

/*
 有一些球形气球贴在一堵用XY平面表示的墙面上。墙面上的气球记录在整数数组points，其中points[i]=[xstart,xend]表示水平直径在xstart和xend之间的气球。你不知道气球的确切y坐标。
 一支弓箭可以沿着x轴从不同点完全垂直地射出。在坐标x处射出一支箭，若有一个气球的直径的开始和结束坐标为xstart，xend，且满足xstart≤x≤xend，则该气球会被引爆。可以射出的弓箭的数量没有限制。弓箭一旦被射出之后可以无限地前进。
 给你一个数组points，返回引爆所有气球所必须射出的最小弓箭数。
 示例 1：
 输入：points = [[10,16],[2,8],[1,6],[7,12]] 输出：2
 解释：气球可以用2支箭来爆破:
 -在x = 6处射出箭，击破气球[2,8]和[1,6]。
 -在x = 11处发射箭，击破气球[10,16]和[7,12]。
 示例 2：
 输入：points = [[1,2],[3,4],[5,6],[7,8]]  输出：4
 解释：每个气球需要射出一支箭，总共需要4支箭。
 示例 3：
 输入：points = [[1,2],[2,3],[3,4],[4,5]] 输出：2
 解释：气球可以用2支箭来爆破:
 - 在x = 2处发射箭，击破气球[1,2]和[2,3]。
 - 在x = 4处射出箭，击破气球[3,4]和[4,5]。
 */

public class MinimumNumberofArrowstoBurstBalloons {
    public class func findMinArrowShots(_ points: [[Int]]) -> Int {
        
        guard points.count > 0 else { return 0}
        
        let sortArray:[[Int]] = points.sorted { p1, p2 in
            return p1[0] < p2[0]
        }
        
        var overlayArray = [[Int]]()
        overlayArray.append(sortArray[0])
        for i in 1 ..< sortArray.count {
            let minV:Int = sortArray[i][0]
            let maxV:Int = sortArray[i][1]
            
            var edit: Bool = false
            for j in 0 ..< overlayArray.count {
                let cMinV:Int = overlayArray[j][0]
                let cMaxV:Int = overlayArray[j][1]
                
                if (minV <= cMinV && cMinV <= maxV) || (cMinV <= minV && minV <= cMaxV) {
                    overlayArray[j][0] = max(minV, cMinV)
                    overlayArray[j][1] = min(maxV, cMaxV)
                    edit = true
                    break
                }
            }
            if !edit {
                overlayArray.append(sortArray[i])
            }
        }
        return overlayArray.count
    }
}
