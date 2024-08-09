//
//  0098_ValidateBinarySearchTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/8/8.
//

import Foundation

public class ValidateBinarySearchTree {
    
    /// 递归解法
    /// 在任意结点，当前结点的是左边所有结点的最大值，是右边所有结点的最小值
    public class func isValidBST(_ root: TreeNode?) -> Bool {
        guard root != nil else {return false}
        return recursiveBST(root, Int.min, Int.max)
    }
    
    public class func recursiveBST(_ root: TreeNode?, _ lower: Int, _ upper: Int) -> Bool {
        guard let node = root else {return true}
        
        if node.val <= lower || node.val >= upper {
            return false
        }
        
        return recursiveBST(node.left, lower, node.val) && recursiveBST(node.right, node.val, upper)
    }
    
    /// 中序遍历解法（循环遍历）
    public class func isValidBST1(_ root: TreeNode?) -> Bool {
        guard root != nil else {return false}
        
        var stack: [TreeNode]? = [TreeNode]()
        var curNode = root
        var value: Int = Int.min
        while stack?.isEmpty == false || curNode != nil {
            
            if let node = curNode {
                stack?.append(node)
                curNode = node.left
            } else {
                curNode = stack?.removeLast()
                
                if curNode!.val <= value { // 当前值小于上一次比较的值则不符合
                    return false
                }
                
                value = curNode!.val
                curNode = curNode?.right
            }
        }
        return true
    }
    
    
}
