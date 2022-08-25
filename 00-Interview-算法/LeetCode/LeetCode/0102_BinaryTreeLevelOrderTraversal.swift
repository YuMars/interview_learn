//
//  0102_BinaryTreeLevelOrderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class BinaryTreeLevelOrderTraversal {
    public class func levelOrder(_ root: TreeNode?) -> [[Int]] {
        var res = [[Int]]()
        guard let _ = root else { return res}
        
        var queue = [root]
        while !queue.isEmpty {
            let count = queue.count
            var subArray = [Int]()
            for _ in 0..<count {
                let node = queue.removeFirst()
                subArray.append(node!.val)
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            res.append(subArray)
        }
        return res
    }
}
