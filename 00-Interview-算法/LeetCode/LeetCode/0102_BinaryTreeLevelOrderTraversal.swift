//
//  0102_BinaryTreeLevelOrderTraversal.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class BinaryTreeLevelOrderTraversal {
    public class func levelOrder(_ root: TreeNode?) -> [[Int]] {
        var res = [[Int]]()
        guard let _ = root else { return res}
        
        var queue = [root]
        while !queue.isEmpty {
            let count = queue.count
            var subArray = [Int]()
            for _ in 0..<count {
                let node = queue.removeFirst()
                subArray.append(node!.val)
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            res.append(subArray)
        }
        return res
    }
    
    
    public class func levelOrder1(_ root: TreeNode?) -> [[Int]] {
        guard root != nil else {return []}
        
        var result:[[Int]] = [[Int]]()
        var queue: [TreeNode?] = [TreeNode?]()
        
        queue.append(root)
        while !queue.isEmpty {
            
            var levelArray: [Int] = [Int]()
            let count: Int = queue.count
            
            for _ in 0..<count {
                let node: TreeNode! = queue.removeFirst()
                levelArray.append(node!.val)
                
                if let left = node?.left {
                    queue.append(left)
                }
                
                if let right = node?.right {
                    queue.append(right)
                }
            }
            result.append(levelArray)
        }
        
        return result
    }
}
