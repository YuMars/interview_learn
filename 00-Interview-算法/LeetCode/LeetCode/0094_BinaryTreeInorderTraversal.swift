//
//  0094_BinaryTreeInorderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/15.
//

import Foundation

// 二叉树中序遍历 左中右
public class BinaryTreeInorderTraversal {
    public class func inorderTraversal(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        inorder(root, &res)
        return res
    }
    
    class func inorder(_ treeNode: TreeNode?, _ res: inout [Int]) {
        guard let node = treeNode else { return }
        inorder(node.left, &res)
        res.append(node.val)
        inorder(node.right, &res)
    }
    
    public class func inorderTraversal2(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        guard let _ = root else { return res }
        var stack:[TreeNode]! = [TreeNode]()
        var currentNode: TreeNode! = root
        while currentNode != nil || !stack.isEmpty {
            if let node = currentNode { // 先访问到最左叶子
                stack.append(node)
                currentNode = currentNode?.left // 左节点
            } else {
                currentNode = stack.removeLast()
                res.append(currentNode.val) // 中间节点
                currentNode = currentNode.right // 右节点
            }
        }
        return res
    }
}
