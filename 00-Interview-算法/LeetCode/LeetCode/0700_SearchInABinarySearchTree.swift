//
//  0700_SearchInABinarySearchTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/23.
//

import Foundation

public class SearchInABinarySearchTree {
    
    // 迭代
    public class func searchBST(_ root: TreeNode?, _ val: Int) -> TreeNode? {
        var root = root
        while root != nil {
            if root!.val > val {
                root = root!.left
            } else if root!.val < val {
                root = root!.right
            } else {
                return root
            }
        }
        
        return nil
    }
    
    // 递归
    public class func searchBST2(_ root: TreeNode?, _ val: Int) -> TreeNode? {
        if (root == nil || root?.val == val) { return root }
        
        var result: TreeNode? = nil
        if root!.val > val {
            result = searchBST(root!.left, val)
        }
        
        if root!.val < val {
            result = searchBST(root!.right, val)
        }
        return result
    }
    
    
    
}
