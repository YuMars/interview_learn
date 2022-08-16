//
//  0145_BinaryTreePostorderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/15.
//

import Foundation

// 二叉树后序遍历 左右中
public class BinaryTreePostorderTraversal {
    public class func postorderTraversal(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        postorder(root, &res)
        return res
    }
    
    class func postorder(_ treeNode: TreeNode?, _ res: inout [Int]) {
        guard let node = treeNode else { return }
        postorder(node.left, &res)
        postorder(node.right, &res)
        res.append(node.val)
    }
    
    public class func postorderTraversal2(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        guard let _ = root else { return res }
        var stack = [root]
        while !stack.isEmpty {
            let currentNode = stack.removeLast()
            // 与前序相反，即中右左，最后结果还需反转才是后序
            if let node = currentNode?.left { //
                stack.append(node)
            }
            
            if let node = currentNode?.right {
                stack.append(node)
            }
            
            res.append(currentNode!.val)
        }
        
        return res.reversed()
    }
}
