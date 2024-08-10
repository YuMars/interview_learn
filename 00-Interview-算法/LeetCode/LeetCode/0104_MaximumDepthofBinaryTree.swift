//
//  0104_MaximumDepthofBinaryTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

/*
 二叉树的 最大深度 是指从根节点到最远叶子节点的最长路径上的节点数。
 */

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
    
    /// 迭代法
    public class func maxDepth1(_ root: TreeNode?) -> Int {
        guard root != nil else {return 0}
        var result: Int = 0
        
        var queue: [TreeNode?] = [TreeNode]()
        queue.append(root)
        
        while !queue.isEmpty {
            let count: Int = queue.count
            for _ in 0..<count {
                let node = queue.removeFirst()
                if let node = node?.left {
                    queue.append(node)
                }
                if let node = node?.right {
                    queue.append(node)
                }
            }
            
            
            result += 1
        }
        return result
    }
    
    /// 回溯解法
    public class func maxDepth2(_ root: TreeNode?) -> Int {
        guard root != nil else {return 0}
        var result: Int = 0
        recursiveDepth(root, &result)
        return result
    }
    
    public class func recursiveDepth(_ root: TreeNode?, _ result: inout Int) {
        
        if root == nil { return }
        
        result += 1
        recursiveDepth(root?.left, &result)
        recursiveDepth(root?.right, &result)
        result -= 1
        
    }
}
