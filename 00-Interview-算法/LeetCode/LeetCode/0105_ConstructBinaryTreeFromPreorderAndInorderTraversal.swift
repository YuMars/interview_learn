//
//  0105_ConstructBinaryTreeFromPreorderAndInorderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/8/15.
//

import Foundation

/*
 给定两个整数数组 preorder 和 inorder ，其中 preorder 是二叉树的先序遍历， inorder 是同一棵树的中序遍历，请构造二叉树并返回其根节点。
 
 x - (preL + 1) = pIndex - 1 - inL
 x = pIndex - inL + preL
 
      |  根节点  |       左子树          ||        右子树         |
      ↑         ↑                      ↑↑                      ↑
     preL    preL+ 1   pIndex-inL+pIndex pIndex-inL+pIndex+1  preR
 
      |       左子树          ||  根节点  ||        右子树         |
      ↑                      ↑     ↑     ↑                      ↑
      inL              pIndex-1  pIndex  pIndex + 1            inR

 */

public class ConstructBinaryTreeFromPreorderAndInorderTraversal {
    
    
    // 递归解法
    public class func buildTree(_ preorder: [Int], _ inorder: [Int]) -> TreeNode? {
        // 计算前序遍历和中序遍历的长度
        let preCount: Int = preorder.count
        let inCount: Int = inorder.count
        
        // 遍历中序遍历生成map，key是中序遍历的值，value是中序遍历的index（用于快速查找根节点）
        var map: [Int : Int] = [Int : Int]()
        for (index ,value) in inorder.enumerated() {
            map[value] = index
        }
        
        // 构建递归函数
        
        return recursiveTree(preorder,0 , preCount - 1, map, 0, inCount - 1)
    }
    
    /// 递归：
    /// 前序遍历的左子树的左右index = 中序遍历的左子树的左右index
    /// 前序遍历的右子树的左右index = 中序遍历的右子树的左右index
    
    public class func recursiveTree(_ preOrder:[Int], _ preOrderLeft: Int, _ preOrderRight: Int, _ map: [Int : Int],_ inOrderLeft: Int, _ inOrderRight: Int) -> TreeNode? {
        
        // 左边界不能大于右边界，否则这个结点为nil
        if preOrderLeft > preOrderRight || inOrderLeft > inOrderRight {
            return nil
        }
        
        // 通过前序遍历第一个找根节点
        let rootValue = preOrder[preOrderLeft]
        let root = TreeNode(rootValue)
        let pIndex = map[rootValue]!
        root.left = recursiveTree(preOrder, preOrderLeft + 1, pIndex - inOrderLeft + preOrderLeft, map, inOrderLeft, pIndex - 1)
        
        root.right = recursiveTree(preOrder, pIndex - inOrderLeft + preOrderLeft + 1, preOrderRight, map, pIndex + 1, inOrderRight)
        
        return root
        
    }
}
