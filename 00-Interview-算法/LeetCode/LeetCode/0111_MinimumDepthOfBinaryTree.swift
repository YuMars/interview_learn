//
//  0111_MinimumDepthOfBinaryTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

public class MinimumDepthOfBinaryTree{
    public class func minDepth(_ root: TreeNode?) -> Int {
        guard let _ = root else { return 0 }
        var queue = [root]
        var level = 0
        while !queue.isEmpty {
            let count = queue.count
            level += 1
            for _ in 0..<count {
                let node = queue.removeFirst()
                if node?.left == nil && node?.right == nil {
                    return level
                }
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            
            
        }
        return level
    }
}
