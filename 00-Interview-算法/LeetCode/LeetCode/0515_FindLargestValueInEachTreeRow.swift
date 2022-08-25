//
//  0515_FindLargestValueInEachTreeRow.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

public class FindLargestValueInEachTreeRow {
    public class func largestValues(_ root: TreeNode?) -> [Int] {
        var res: [Int] = [Int]()
        guard let _ = root else { return res }
        var queue = [root]
        while !queue.isEmpty {
            let count: Int = queue.count
            var max: Int = queue[0]!.val
            for _ in 0..<count {
                let node = queue.removeFirst()
                
                if node!.val > max {
                    max = node!.val
                }
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
                
            }
            res.append(max)
        }
        return res
    }
}
