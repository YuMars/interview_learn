//
//  0104_MaximumDepthofBinaryTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

public class MaximumDepthofBinaryTree {
    public class func maxDepth(_ root: TreeNode?) -> Int {
        guard let _ = root else { return 0 }
        
        var queue = [root]
        var level = 0
        while !queue.isEmpty {
            let count = queue.count
            for _ in 0..<count {
                let node = queue.removeFirst()
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            
            level += 1
        }
        
        return level
    }
}
