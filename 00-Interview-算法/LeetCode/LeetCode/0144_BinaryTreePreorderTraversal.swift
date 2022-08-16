//
//  0144_BinaryTreePreorderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/15.
//

import Foundation

// 二叉树前序遍历  左中右
public class BinaryTreePreorderTraversal {
    // 递归
    public class func preorderTraversal(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        preorder(root, &res)
        return res
    }
    
    class func preorder(_ treeNode: TreeNode?, _ res: inout [Int]) {
        guard let node = treeNode else { return }
        res.append(node.val)
        preorder(node.left, &res)
        preorder(node.right, &res)
    }
    
    public class func preorderTraversal2(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        guard let _ = root else { return res}
        
        var stack = [root]
        while !stack.isEmpty {
            if let currentNode = stack.removeLast() {
                if let node = currentNode.right {
                    stack.append(node)
                }
                if let node = currentNode.left {
                    stack.append(node)
                }
                res.append(currentNode.val)
            }
        }
        return res
    }
}
