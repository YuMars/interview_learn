//
//  0429_N-aryTreeLevelOrderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

public class NaryTreeLevelOrderTraversal {
    public class func levelOrder(_ root: Node?) -> [[Int]] {
        var res = [[Int]]()
        guard let _ = root else { return res }
        var queue = [root]
        
        while !queue.isEmpty {
            let count = queue.count
            var nextLevelArray = [Int]()
            for _ in 0..<count {
                let node = queue.removeFirst()
                nextLevelArray.append(node!.val)
                
                for node in node!.children {
                    queue.append(node)
                }
            }
            res.append(nextLevelArray)
        }
        return res
    }
}
