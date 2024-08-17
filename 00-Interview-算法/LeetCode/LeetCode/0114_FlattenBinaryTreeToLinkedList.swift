//
//  0114_FlattenBinaryTreeToLinkedList.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/8/15.
//

import Foundation

/*
 给你二叉树的根结点 root ，请你将它展开为一个单链表：
 展开后的单链表应该同样使用 TreeNode ，其中 right 子指针指向链表中下一个结点，而左子指针始终为 null。
 展开后的单链表应该与二叉树 先序遍历 顺序相同。
 */

public class FlattenBinaryTreeToLinkedList {
    // 解法一：前序遍历-递归
    public class func flatten(_ root: TreeNode?) {
        var preorderArray: [TreeNode?] = [TreeNode]()
        
        preorderTraveral(root, listArray: &preorderArray)
        print(preorderArray)
        for (i, node) in preorderArray.enumerated() {
            if i > 0 {
                let pre: TreeNode! = preorderArray[i - 1]
                let cur: TreeNode! = preorderArray[i]
                pre.left = nil
                pre.right = cur
            }
        }
    }
    
    public class  func preorderTraveral(_ root: TreeNode?, listArray: inout [TreeNode?]) {
        if let node = root {
            listArray.append(node)
            // print(node.val)
            preorderTraveral(node.left, listArray: &listArray)
            preorderTraveral(node.right, listArray: &listArray)
        }
    }
    
    // 解法一(2)：前序遍历-迭代
    public class func flatten_1(_ root: TreeNode?) {
        guard root != nil else {return }
        var stack: [TreeNode?] = [TreeNode]()
        var preorderArray: [TreeNode?] = [TreeNode]()
        stack.append(root!)
        var node = root
        
        while !stack.isEmpty || node != nil {
            while node != nil {
                preorderArray.append(node)
                stack.append(node)
                node = node?.left
            }
            
            node = stack.removeLast()
            node = node?.right
        }
        
        for (i, val) in preorderArray.enumerated() {
            if i > 0 {
                let pre: TreeNode! = preorderArray[i - 1]
                let cur: TreeNode! = preorderArray[i]
                pre.left = nil
                pre.right = cur
            }
        }
    }
    
    // 解法二：迭代
    public class func flatten1(_ root: TreeNode?) {
        guard root != nil else {return }
        var stack: [TreeNode?] = [TreeNode]()
        stack.append(root!)
        
        var pre: TreeNode? = nil
        
        while !stack.isEmpty {
            let current: TreeNode = stack.removeLast()!
            
            if let node = pre {
                pre?.left = nil
                pre?.right = current
            }
            
            if let node = current.left {
                stack.append(node)
            }
            
            if let node = current.right {
                stack.append(node)
            }
            
            pre = current
        }
    }
    
}
