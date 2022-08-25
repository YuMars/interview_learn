//
//  0226_InvertBinaryTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/19.
//

import Foundation

public class InvertBinaryTree {
    
    // 层序-迭代法
    public class func invertTree(_ root: TreeNode?) -> TreeNode? {
        guard let _ = root else { return root }
        
        var queue = [root]
        
        while !queue.isEmpty {
            let count = queue.count
            for _ in 0..<count {
                let node = queue.removeFirst()
                
                let temp = node?.left
                node?.left = node?.right
                node?.right = temp
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
        }
        return root
    }
    
    // 递归法
    public class func invertTree2(_ root: TreeNode?) -> TreeNode? {
        guard let node = root else { return root }
        swap(&node.left, &node.right)
        _ = invertTree2(node.left)
        _ = invertTree2(node.right)
        return node
    }
}
