//
//  0406_QueueReconstructionbyHeight.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/7.
//

import Foundation

/*
 假设有打乱顺序的一群人站成一个队列，数组people表示队列中一些人的属性（不一定按顺序）。每个people[i]=[hi,ki]表示第i个人的身高为hi前面正好有ki个身高大于或等于hi的人。
 请你重新构造并返回输入数组 people 所表示的队列。返回的队列应该格式化为数组queue其中queue[j]=[hj,kj]是队列中第j个人的属性（queue[0] 是排在队列前面的人）
 示例 1：
 输入：people = [[7,0],[4,4],[7,1],[5,0],[6,1],[5,2]]
 输出：[[5,0],[7,0],[5,2],[6,1],[4,4],[7,1]]
 解释：
 编号为 0 的人身高为 5 ，没有身高更高或者相同的人排在他前面。
 编号为 1 的人身高为 7 ，没有身高更高或者相同的人排在他前面。
 编号为 2 的人身高为 5 ，有 2 个身高更高或者相同的人排在他前面，即编号为 0 和 1 的人。
 编号为 3 的人身高为 6 ，有 1 个身高更高或者相同的人排在他前面，即编号为 1 的人。
 编号为 4 的人身高为 4 ，有 4 个身高更高或者相同的人排在他前面，即编号为 0、1、2、3 的人。
 编号为 5 的人身高为 7 ，有 1 个身高更高或者相同的人排在他前面，即编号为 1 的人。
 因此 [[5,0],[7,0],[5,2],[6,1],[4,4],[7,1]] 是重新构造后的队列。
 示例 2：
 输入：people = [[6,0],[5,0],[4,0],[3,2],[2,2],[1,4]]
 输出：[[4,0],[5,0],[2,2],[3,2],[1,4],[6,0]
 */

public class QueueReconstructionbyHeight {
    
    public class func reconstructQueue(_ people: [[Int]]) -> [[Int]] {
        let queue = people.sorted { p1, p2 in
            
            if p1[0] != p2[0] {
                return p1[0] >= p2[0]
            } else {
                return p1[1] < p2[1]
            }
            
            //return p1[0] >= p2[0] && p1[1] < p2[1]
        }
        
        var result = [[Int]]()
        for item in queue {
            result.insert(item, at: item[1])
        }
        
        return result
    }
    
    public class func reconstructQueue2(_ people: [[Int]]) -> [[Int]] {
        let queue = people.sorted { p1, p2 in
            
            if p1[0] != p2[0] {
                return p1[0] >= p2[0]
            } else {
                return p1[1] < p2[1]
            }
            
            //return p1[0] >= p2[0] && p1[1] < p2[1]
        }
        
        var result = [[Int]]()
        result.append(queue[0])
        for i in 1 ..< queue.count {
            
            let value = queue[i][0]
            let index = queue[i][1]
            for j in 0 ..< result.count {
                let curValue = result[j][0]
                if index == j {
                    
                    if value <= curValue {
                        result.insert(queue[i], at: j)
                        break
                    } else {
                        result.append(queue[i])
                        break
                    }
                    
                } else if (j + 1) == result.count {
                    result.append(queue[i])
                    break
                } else { /* index > j*/
                    continue
                }
            }
        }
        return result
    }
}
